-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 12, 2026 at 01:34 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `wcms`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_vehicle` (IN `p_vehicle_number` VARCHAR(50), IN `p_capacity_kg` INT)   BEGIN
    -- 1. Validate vehicle number
    IF p_vehicle_number IS NULL OR p_vehicle_number = '' THEN
        SELECT 'Vehicle number is required' AS msg;

    -- 2. Validate capacity
    ELSEIF p_capacity_kg IS NULL OR p_capacity_kg <= 0 THEN
        SELECT 'Vehicle capacity must be greater than 0' AS msg;

    -- 3. Prevent duplicate
    ELSEIF EXISTS (SELECT 1 FROM vehicles WHERE vehicle_number = p_vehicle_number) THEN
        SELECT 'Vehicle already exists' AS msg;

    ELSE
        -- 4. Insert vehicle (current_load_kg and status use defaults)
        INSERT INTO vehicles (
            vehicle_number,
            capacity_kg
        ) VALUES (
            p_vehicle_number,
            p_capacity_kg
        );

        -- 5. Notify all admins and supervisors
        INSERT INTO notifications (user_id, message)
        SELECT u.id,
               CONCAT(
                   'New vehicle added: ', p_vehicle_number,
                   ' | Capacity: ', p_capacity_kg, ' kg. Ready for assignment.'
               )
        FROM users u
        JOIN roles r ON r.id = u.role_id
        WHERE r.name IN ('admin','supervisor');

        -- 6. Return success message
        SELECT 'Vehicle added successfully' AS msg;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_approve_bin_request` (IN `p_request_id` INT, IN `p_vehicle_id` INT, IN `p_driver_id` INT, IN `p_collection_date` DATE, IN `p_created_by` INT)   BEGIN
    DECLARE v_area_id INT;
    DECLARE v_bin_id INT;
    DECLARE v_schedule_id INT;

    /* =========================
       1. BASIC VALIDATION
    ========================= */

    IF p_request_id IS NULL THEN
        SELECT 'Request ID is required' AS msg;

    ELSEIF p_vehicle_id IS NULL THEN
        SELECT 'Vehicle is required' AS msg;

    ELSEIF p_driver_id IS NULL THEN
        SELECT 'Driver is required' AS msg;

    ELSEIF p_created_by IS NULL THEN
        SELECT 'Creator is required' AS msg;

    ELSEIF p_collection_date IS NULL THEN
        SELECT 'Collection date is required' AS msg;

    ELSEIF p_collection_date < CURDATE() THEN
        SELECT 'Collection date cannot be in the past' AS msg;

    /* =========================
       2. REQUEST VALIDATION
    ========================= */

    ELSEIF NOT EXISTS (
        SELECT 1
        FROM waste_request
        WHERE id = p_request_id
          AND status = 'pending'
          AND request_target = 'bin'
    ) THEN
        SELECT 'Invalid, non-bin, or already processed request' AS msg;

    /* =========================
       3. VEHICLE VALIDATION
    ========================= */

    ELSEIF NOT EXISTS (
        SELECT 1 FROM vehicles
        WHERE id = p_vehicle_id
          AND status = 'available'
    ) THEN
        SELECT 'Selected vehicle is not available' AS msg;

    /* =========================
       4. DRIVER VALIDATION
    ========================= */

    ELSEIF NOT EXISTS (
        SELECT 1
        FROM users u
        JOIN roles r ON r.id = u.role_id
        WHERE u.id = p_driver_id
          AND r.name = 'driver'
          AND u.status = 'active'
    ) THEN
        SELECT 'Selected user is not an active driver' AS msg;

    /* =========================
       5. CREATOR VALIDATION
    ========================= */

    ELSEIF NOT EXISTS (
        SELECT 1
        FROM users u
        JOIN roles r ON r.id = u.role_id
        WHERE u.id = p_created_by
          AND r.name IN ('admin','supervisor')
    ) THEN
        SELECT 'Only admin or supervisor can approve requests' AS msg;

    /* =========================
       6. PROCESS APPROVAL
    ========================= */

    ELSE
        /* ---- Get area & bin ---- */
        SELECT area_id, bin_id
        INTO v_area_id, v_bin_id
        FROM waste_request
        WHERE id = p_request_id;

        /* ---- Approve request ---- */
        UPDATE waste_request
        SET status = 'approved'
        WHERE id = p_request_id;

        /* ---- Mark bin as FULL ---- */
        UPDATE bins
        SET status = 'full',
            updated_at = NOW()
        WHERE id = v_bin_id;

        /* ---- Check existing schedule ---- */
        SELECT id
        INTO v_schedule_id
        FROM collection_schedule
        WHERE area_id = v_area_id
          AND collection_date = p_collection_date
          AND status IN ('scheduled','in_progress')
        LIMIT 1;

        /* ---- Create schedule if not exists ---- */
        IF v_schedule_id IS NULL THEN

            INSERT INTO collection_schedule (
                area_id,
                vehicle_id,
                driver_id,
                collection_date,
                created_by
            ) VALUES (
                v_area_id,
                p_vehicle_id,
                p_driver_id,
                p_collection_date,
                p_created_by
            );

            SET v_schedule_id = LAST_INSERT_ID();

            UPDATE vehicles
            SET status = 'on_route',
                updated_at = NOW()
            WHERE id = p_vehicle_id;

        END IF;

        /* ---- Link request to schedule ---- */
        UPDATE waste_request
        SET schedule_id = v_schedule_id
        WHERE id = p_request_id;

        SELECT 'Bin request approved and scheduled successfully' AS msg;

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_approve_bin_request_lst` (IN `p_request_id` INT, IN `p_vehicle_id` INT, IN `p_driver_id` INT, IN `p_collection_date` DATE, IN `p_created_by` INT)   BEGIN
    DECLARE v_area_id INT;
    DECLARE v_bin_id INT;
    DECLARE v_schedule_id INT;

    /* =========================
       1. BASIC VALIDATION
    ========================= */

    IF p_request_id IS NULL THEN
        SELECT 'Request ID is required' AS msg;

    ELSEIF p_vehicle_id IS NULL THEN
        SELECT 'Vehicle is required' AS msg;

    ELSEIF p_driver_id IS NULL THEN
        SELECT 'Driver is required' AS msg;

    ELSEIF p_collection_date IS NULL THEN
        SELECT 'Collection date is required' AS msg;

    ELSEIF p_created_by IS NULL THEN
        SELECT 'Creator is required' AS msg;

    /* =========================
       2. REQUEST EXISTS & PENDING
    ========================= */

    ELSEIF NOT EXISTS (
        SELECT 1
        FROM waste_request
        WHERE id = p_request_id
          AND request_target = 'bin'
          AND status = 'pending'
    ) THEN
        SELECT 'Request not found or not pending' AS msg;

    /* =========================
       3. LOAD AREA & BIN
    ========================= */

    ELSE
        SELECT area_id, bin_id
        INTO v_area_id, v_bin_id
        FROM waste_request
        WHERE id = p_request_id;

        /* =========================
           4. BIN VALIDATION
        ========================= */

      IF NOT EXISTS (
    SELECT 1
    FROM bins b
    JOIN areas a ON b.area_id = a.id
    WHERE b.id = v_bin_id
      AND a.name = (SELECT name FROM areas WHERE id = v_area_id)
) THEN
    SELECT 'Bin does not belong to the selected area' AS msg;
        /* =========================
           5. VEHICLE VALIDATION
        ========================= */

        ELSEIF NOT EXISTS (
            SELECT 1 FROM vehicles
            WHERE id = p_vehicle_id
              AND status = 'available'
        ) THEN
            SELECT 'Vehicle is not available' AS msg;

        /* =========================
           6. DRIVER VALIDATION
        ========================= */

        ELSEIF NOT EXISTS (
            SELECT 1
            FROM users u
            JOIN roles r ON r.id = u.role_id
            WHERE u.id = p_driver_id
              AND r.name = 'driver'
              AND u.status = 'active'
        ) THEN
            SELECT 'User is not an active driver' AS msg;

        /* =========================
           7. ADMIN / SUPERVISOR CHECK
        ========================= */

        ELSEIF NOT EXISTS (
            SELECT 1
            FROM users u
            JOIN roles r ON r.id = u.role_id
            WHERE u.id = p_created_by
              AND r.name IN ('admin','supervisor')
        ) THEN
            SELECT 'Only admin or supervisor can approve requests' AS msg;

        /* =========================
           8. DATE VALIDATION
        ========================= */

        ELSEIF p_collection_date < CURDATE() THEN
            SELECT 'Collection date cannot be in the past' AS msg;

        /* =========================
           9. DRIVER AVAILABILITY
           (🚨 FIXED LOGIC BUG)
        ========================= */

        ELSEIF EXISTS (
            SELECT 1
            FROM collection_schedule
            WHERE driver_id = p_driver_id
              AND collection_date = p_collection_date
              AND status IN ('scheduled','in_progress')
        ) THEN
            SELECT 'Driver is already assigned to another schedule on this date' AS msg;

        /* =========================
           10. AREA DUPLICATE CHECK
        ========================= */

        ELSEIF EXISTS (
            SELECT 1
            FROM collection_schedule
            WHERE area_id = v_area_id
              AND collection_date = p_collection_date
              AND status IN ('scheduled','in_progress')
        ) THEN
            SELECT 'This area already has an active schedule on this date' AS msg;

        /* =========================
           11. CREATE SCHEDULE
        ========================= */

        ELSE
            INSERT INTO collection_schedule (
                area_id,
                vehicle_id,
                driver_id,
                collection_date,
                created_by
            ) VALUES (
                v_area_id,
                p_vehicle_id,
                p_driver_id,
                p_collection_date,
                p_created_by
            );

            SET v_schedule_id = LAST_INSERT_ID();

            /* =========================
               12. UPDATE REQUEST
            ========================= */

            UPDATE waste_request
            SET status = 'approved',
                schedule_id = v_schedule_id
            WHERE id = p_request_id;

            /* =========================
               13. UPDATE BIN STATUS
            ========================= */

            UPDATE bins
            SET status = 'full'
            WHERE id = v_bin_id;

            /* =========================
               14. UPDATE VEHICLE STATUS
            ========================= */

            UPDATE vehicles
            SET status = 'on_route'
            WHERE id = p_vehicle_id;

            /* =========================
               15. SUCCESS
            ========================= */

            SELECT 'Bin request approved and schedule created successfully' AS msg;
        END IF;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_approve_house_hold_request` (IN `p_request_id` INT, IN `p_vehicle_id` INT, IN `p_driver_id` INT, IN `p_collection_date` DATE, IN `p_created_by` INT)   BEGIN
    DECLARE v_area_id INT;
    DECLARE v_address VARCHAR(255);
    DECLARE v_schedule_id INT;

    /* =========================
       1. BASIC VALIDATION
    ========================= */

    IF p_request_id IS NULL THEN
        SELECT 'Request ID is required' AS msg;

    ELSEIF p_vehicle_id IS NULL THEN
        SELECT 'Vehicle is required' AS msg;

    ELSEIF p_driver_id IS NULL THEN
        SELECT 'Driver is required' AS msg;

    ELSEIF p_collection_date IS NULL THEN
        SELECT 'Collection date is required' AS msg;

    ELSEIF p_created_by IS NULL THEN
        SELECT 'Creator is required' AS msg;

    /* =========================
       2. REQUEST EXISTS & PENDING
    ========================= */

    ELSEIF NOT EXISTS (
        SELECT 1
        FROM waste_request
        WHERE id = p_request_id
          AND request_target = 'house_hold'
          AND status = 'pending'
    ) THEN
        SELECT 'Request not found or not pending' AS msg;

    /* =========================
       3. LOAD AREA & ADDRESS
    ========================= */

    ELSE
        SELECT area_id, address
        INTO v_area_id, v_address
        FROM waste_request
        WHERE id = p_request_id;

        /* =========================
           4. ADDRESS VALIDATION
        ========================= */

        IF v_address IS NULL OR TRIM(v_address) = '' THEN
            SELECT 'House hold address is required' AS msg;

        /* =========================
           5. VEHICLE VALIDATION
        ========================= */

        ELSEIF NOT EXISTS (
            SELECT 1
            FROM vehicles
            WHERE id = p_vehicle_id
              AND status = 'available'
        ) THEN
            SELECT 'Vehicle is not available' AS msg;

        /* =========================
           6. DRIVER VALIDATION
        ========================= */

        ELSEIF NOT EXISTS (
            SELECT 1
            FROM users u
            JOIN roles r ON r.id = u.role_id
            WHERE u.id = p_driver_id
              AND r.name = 'driver'
              AND u.status = 'active'
        ) THEN
            SELECT 'User is not an active driver' AS msg;

        /* =========================
           7. ADMIN / SUPERVISOR CHECK
        ========================= */

        ELSEIF NOT EXISTS (
            SELECT 1
            FROM users u
            JOIN roles r ON r.id = u.role_id
            WHERE u.id = p_created_by
              AND r.name IN ('admin','supervisor')
        ) THEN
            SELECT 'Only admin or supervisor can approve requests' AS msg;

        /* =========================
           8. DATE VALIDATION
        ========================= */

        ELSEIF p_collection_date < CURDATE() THEN
            SELECT 'Collection date cannot be in the past' AS msg;

        /* =========================
           9. DRIVER AVAILABILITY
        ========================= */

        ELSEIF EXISTS (
            SELECT 1
            FROM collection_schedule
            WHERE driver_id = p_driver_id
              AND collection_date = p_collection_date
              AND status IN ('scheduled','in_progress')
        ) THEN
            SELECT 'Driver is already assigned to another schedule on this date' AS msg;

        /* =========================
           10. AREA DUPLICATE CHECK
        ========================= */

        ELSEIF EXISTS (
            SELECT 1
            FROM collection_schedule
            WHERE area_id = v_area_id
              AND collection_date = p_collection_date
              AND status IN ('scheduled','in_progress')
        ) THEN
            SELECT 'This area already has an active schedule on this date' AS msg;

        /* =========================
           11. CREATE SCHEDULE
        ========================= */

        ELSE
            INSERT INTO collection_schedule (
                area_id,
                vehicle_id,
                driver_id,
                collection_date,
                created_by
            ) VALUES (
                v_area_id,
                p_vehicle_id,
                p_driver_id,
                p_collection_date,
                p_created_by
            );

            SET v_schedule_id = LAST_INSERT_ID();

            /* =========================
               12. UPDATE REQUEST
            ========================= */

            UPDATE waste_request
            SET status = 'approved',
                schedule_id = v_schedule_id
            WHERE id = p_request_id;

            /* =========================
               13. UPDATE VEHICLE STATUS
            ========================= */

            UPDATE vehicles
            SET status = 'on_route'
            WHERE id = p_vehicle_id;

            /* =========================
               14. SUCCESS
            ========================= */

            SELECT 'House hold request approved and schedule created successfully' AS msg;

        END IF;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_bin_collection_report` (IN `p_type` VARCHAR(10), IN `p_from_date` DATE, IN `p_to_date` DATE)   BEGIN

    IF p_type = '0' THEN

        SELECT 
            cl.id,
            u.full_name AS driver,
            v.vehicle_number AS vehicle,
            CONCAT(a.name, '_', a.zone) AS Area,
            b.bin_code,
            date(cl.collected_at) 'colected_at'
        FROM collection_logs cl
        JOIN collection_schedule cs ON cl.schedule_id = cs.id
        JOIN users u ON cs.driver_id = u.id
        JOIN vehicles v ON cs.vehicle_id = v.id
        JOIN bins b ON cl.bin_id = b.id
        JOIN areas a ON b.area_id = a.id
        ORDER BY  date(cl.collected_at) DESC;

    ELSEIF p_type = 'custom' THEN

        SELECT 
            cl.id,
            u.full_name AS driver,
            v.vehicle_number AS vehicle,
            CONCAT(a.name, '_', a.zone) AS Area,
            b.bin_code,
            date(cl.collected_at) 'colected_at'
        FROM collection_logs cl
        JOIN collection_schedule cs ON cl.schedule_id = cs.id
        JOIN users u ON cs.driver_id = u.id
        JOIN vehicles v ON cs.vehicle_id = v.id
        JOIN bins b ON cl.bin_id = b.id
        JOIN areas a ON b.area_id = a.id
        WHERE DATE(cl.collected_at) BETWEEN p_from_date AND p_to_date
        ORDER BY cl.collected_at DESC;

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_collection_schedule_by_status` (IN `p_status` VARCHAR(20))   BEGIN

SELECT 
    cs.id AS schedule_id,
    cs.collection_date,
    a.name AS District,
    u.full_name AS driver,
    v.vehicle_number AS vehicle,
    cs.status
FROM collection_schedule cs
JOIN users u ON cs.driver_id = u.id
JOIN vehicles v ON cs.vehicle_id = v.id
JOIN areas a ON cs.area_id = a.id
WHERE 
    p_status = 'all'
    OR cs.status = p_status
ORDER BY cs.collection_date DESC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_collect_bin` (IN `p_schedule_id` INT, IN `p_driver_id` INT, IN `p_request_id` INT, IN `p_bin_id` INT)   BEGIN

    DECLARE v_vehicle_id INT;

    /* =========================
       1. VALIDATE SCHEDULE
    ========================= */
    IF NOT EXISTS (
        SELECT 1
        FROM collection_schedule
        WHERE id = p_schedule_id
          AND driver_id = p_driver_id
          AND status = 'in_progress'
    ) THEN
        SELECT 'Schedule not active or invalid driver' AS msg;

    /* =========================
       2. VALIDATE REQUEST
    ========================= */
    ELSEIF NOT EXISTS (
        SELECT 1
        FROM waste_request
        WHERE id = p_request_id
          AND schedule_id = p_schedule_id
          AND status = 'approved'
    ) THEN
        SELECT 'Invalid or already collected request' AS msg;

    /* =========================
       3. VALIDATE BIN
    ========================= */
    ELSEIF NOT EXISTS (
        SELECT 1
        FROM bins
        WHERE id = p_bin_id
          AND status = 'full'
    ) THEN
        SELECT 'Bin not ready for collection' AS msg;

    ELSE

        /* =========================
           4. INSERT COLLECTION LOG
           (weight not required)
        ========================= */
        INSERT INTO collection_logs(
            schedule_id,
            bin_id,
            request_id
        )
        VALUES(
            p_schedule_id,
            p_bin_id,
            p_request_id
        );

        /* =========================
           5. EMPTY BIN
        ========================= */
        UPDATE bins
        SET status = 'empty',
            current_level_kg = 0,
            last_collected_at = NOW(),
            updated_at = NOW()
        WHERE id = p_bin_id;

        /* =========================
           6. UPDATE REQUEST STATUS
        ========================= */
        UPDATE waste_request
        SET status = 'collected'
        WHERE id = p_request_id;

        SELECT 'Collection completed successfully' AS msg;

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_collect_household_waste` (IN `p_schedule_id` INT, IN `p_driver_id` INT, IN `p_request_id` INT)   BEGIN

    /* =========================
       1. VALIDATE SCHEDULE
    ========================= */
    IF NOT EXISTS (
        SELECT 1
        FROM collection_schedule
        WHERE id = p_schedule_id
          AND driver_id = p_driver_id
          AND status = 'in_progress'
    ) THEN
        SELECT 'Schedule not active or invalid driver' AS msg;

    /* =========================
       2. VALIDATE HOUSEHOLD REQUEST
    ========================= */
    ELSEIF NOT EXISTS (
        SELECT 1
        FROM waste_request
        WHERE id = p_request_id
          AND schedule_id = p_schedule_id
          AND status = 'approved'
          AND request_target = 'house_hold'
    ) THEN
        SELECT 'Invalid or already collected household request' AS msg;

    ELSE

        /* =========================
           3. INSERT COLLECTION LOG
           (household collection)
        ========================= */
        INSERT INTO collection_logs (
            schedule_id,
            request_id
        )
        VALUES (
            p_schedule_id,
            p_request_id
        );

        /* =========================
           4. UPDATE REQUEST STATUS
        ========================= */
        UPDATE waste_request
        SET status = 'collected'
        WHERE id = p_request_id;

        SELECT 'Household collection completed successfully' AS msg;

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_complete_household_schedule` (IN `p_schedule_id` INT, IN `p_driver_id` INT)   BEGIN

    /* =========================
       1. CHECK UNCOLLECTED HOUSEHOLD REQUESTS
    ========================= */
    IF EXISTS (
        SELECT 1
        FROM waste_request
        WHERE schedule_id = p_schedule_id
          AND status = 'approved'
          AND request_target = 'house_hold'
    ) THEN

        SELECT 'Some household requests are still not collected' AS msg;

    ELSE

        /* =========================
           2. COMPLETE SCHEDULE
        ========================= */
        UPDATE collection_schedule
        SET status = 'completed',
            completed_at = NOW()
        WHERE id = p_schedule_id
          AND driver_id = p_driver_id
          AND status = 'in_progress';

        /* =========================
           3. RELEASE VEHICLE
        ========================= */
        UPDATE vehicles
        SET status = 'available'
        WHERE id = (
            SELECT vehicle_id
            FROM collection_schedule
            WHERE id = p_schedule_id
        );

        SELECT 'Household schedule completed successfully' AS msg;

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_complete_schedule` (IN `p_schedule_id` INT, IN `p_driver_id` INT)   BEGIN

    /* Check if uncollected bins still exist */
    IF EXISTS (
        SELECT 1
        FROM waste_request wr
        JOIN bins b ON b.id = wr.bin_id
        WHERE wr.schedule_id = p_schedule_id
          AND wr.status = 'approved'
          AND b.status = 'full'
    ) THEN
        SELECT 'Some bins are still not collected' AS msg;

    ELSE

        UPDATE collection_schedule
        SET status = 'completed',
            completed_at = NOW()
        WHERE id = p_schedule_id
          AND driver_id = p_driver_id
          AND status = 'in_progress';

        UPDATE vehicles
        SET status = 'available'
        WHERE id = (
            SELECT vehicle_id
            FROM collection_schedule
            WHERE id = p_schedule_id
        );

        SELECT 'Schedule completed successfully' AS msg;

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_collection_schedule` (IN `p_area_id` INT, IN `p_vehicle_id` INT, IN `p_driver_id` INT, IN `p_collection_date` DATE, IN `p_created_by` INT)   BEGIN
    /* =========================
       1. BASIC VALIDATIONS
    ========================= */

    IF p_area_id IS NULL THEN
        SELECT 'Area is required' AS msg;

    ELSEIF p_vehicle_id IS NULL THEN
        SELECT 'Vehicle is required' AS msg;

    ELSEIF p_driver_id IS NULL THEN
        SELECT 'Driver is required' AS msg;

    ELSEIF p_collection_date IS NULL THEN
        SELECT 'Collection date is required' AS msg;

    ELSEIF p_created_by IS NULL THEN
        SELECT 'Creator is required' AS msg;

    /* =========================
       2. EXISTENCE CHECKS
    ========================= */

    ELSEIF NOT EXISTS (SELECT 1 FROM areas WHERE id = p_area_id) THEN
        SELECT 'Area does not exist' AS msg;

    ELSEIF NOT EXISTS (SELECT 1 FROM vehicles WHERE id = p_vehicle_id) THEN
        SELECT 'Vehicle does not exist' AS msg;

    ELSEIF NOT EXISTS (SELECT 1 FROM users WHERE id = p_driver_id) THEN
        SELECT 'Driver does not exist' AS msg;

    ELSEIF NOT EXISTS (SELECT 1 FROM users WHERE id = p_created_by) THEN
        SELECT 'Creator does not exist' AS msg;

    /* =========================
       3. ROLE & STATUS CHECKS
    ========================= */

    ELSEIF NOT EXISTS (
        SELECT 1 FROM users u
        JOIN roles r ON r.id = u.role_id
        WHERE u.id = p_driver_id
          AND r.name = 'driver'
          AND u.status = 'active'
    ) THEN
        SELECT 'User is not an active driver' AS msg;

    ELSEIF NOT EXISTS (
        SELECT 1 FROM users u
        JOIN roles r ON r.id = u.role_id
        WHERE u.id = p_created_by
          AND r.name IN ('admin','supervisor')
    ) THEN
        SELECT 'Only admin or supervisor can create schedule' AS msg;

    /* =========================
       4. VEHICLE AVAILABILITY
    ========================= */

    ELSEIF NOT EXISTS (
        SELECT 1 FROM vehicles
        WHERE id = p_vehicle_id
          AND status = 'available'
    ) THEN
        SELECT 'Vehicle is not available' AS msg;

    /* =========================
       5. DATE LOGIC
    ========================= */

    ELSEIF p_collection_date < CURDATE() THEN
        SELECT 'Collection date cannot be in the past' AS msg;

    /* =========================
       6. DUPLICATE SCHEDULE CHECK
       (Same area + same date)
    ========================= */

    ELSEIF EXISTS (
        SELECT 1 FROM collection_schedule
        WHERE area_id = p_area_id
          AND collection_date = p_collection_date
          AND status IN ('scheduled','in_progress')
    ) THEN
        SELECT 'Collection already scheduled for this area on this date' AS msg;

    /* =========================
       7. CREATE SCHEDULE
    ========================= */

    ELSE
        INSERT INTO collection_schedule (
            area_id,
            vehicle_id,
            driver_id,
            collection_date,
            created_by
        ) VALUES (
            p_area_id,
            p_vehicle_id,
            p_driver_id,
            p_collection_date,
            p_created_by
        );

        /* =========================
           8. UPDATE VEHICLE STATUS
        ========================= */
        UPDATE vehicles
        SET status = 'on_route',
            updated_at = NOW()
        WHERE id = p_vehicle_id;

        /* =========================
           9. NOTIFY DRIVER
        ========================= */
        INSERT INTO notifications (user_id, message)
        VALUES (
            p_driver_id,
            CONCAT(
                'You have been assigned a collection task on ',
                p_collection_date,
                ' for area ID ',
                p_area_id
            )
        );

        /* =========================
           10. NOTIFY ADMINS & SUPERVISORS
        ========================= */
        INSERT INTO notifications (user_id, message)
        SELECT u.id,
               CONCAT(
                   'New collection schedule created for area ID ',
                   p_area_id,
                   ' on ',
                   p_collection_date,
                   '. Vehicle ID ',
                   p_vehicle_id,
                   ' assigned.'
               )
        FROM users u
        JOIN roles r ON r.id = u.role_id
        WHERE r.name IN ('admin','supervisor');

        /* =========================
           11. SUCCESS
        ========================= */
        SELECT 'Collection schedule created successfully' AS msg;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_waste_request` (IN `p_full_name` VARCHAR(100), IN `p_phone` VARCHAR(20), IN `p_request_target` VARCHAR(20), IN `p_area_id` INT, IN `p_bin_id` INT, IN `p_address` VARCHAR(255))   BEGIN
    /* =====================
       1. BASIC VALIDATION
    ====================== */

    IF p_request_target IS NULL OR p_request_target = '' THEN
        SELECT 'Request type is required' AS msg;

    ELSEIF p_area_id IS NULL THEN
        SELECT 'Area is required' AS msg;

    ELSEIF (p_full_name IS NULL OR p_full_name = '')
        AND (p_phone IS NULL OR p_phone = '') THEN
        SELECT 'Full name or phone is required' AS msg;

    /* =====================
       2. VALID REQUEST TYPE
    ====================== */

    ELSEIF p_request_target NOT IN ('bin','house_hold') THEN
        SELECT 'Invalid request type' AS msg;

    /* =====================
       3. AREA EXISTS
    ====================== */

    ELSEIF NOT EXISTS (
        SELECT 1 FROM areas WHERE id = p_area_id
    ) THEN
        SELECT 'Selected area does not exist' AS msg;

    /* =====================
       4. BIN REQUEST VALIDATION
    ====================== */

    ELSEIF p_request_target = 'bin' AND p_bin_id IS NULL THEN
        SELECT 'Bin is required for bin request' AS msg;

    ELSEIF p_request_target = 'bin'
        AND NOT EXISTS (
            SELECT 1
            FROM bins
            WHERE id = p_bin_id
              AND area_id = p_area_id
        ) THEN
        SELECT 'Bin does not belong to selected area' AS msg;

    /* 🔒 Prevent duplicate active bin requests */
    ELSEIF p_request_target = 'bin'
        AND EXISTS (
            SELECT 1
            FROM waste_requests
            WHERE bin_id = p_bin_id
              AND status IN ('pending','approved','assigned')
        ) THEN
        SELECT 'This bin already has an active request' AS msg;

    /* =====================
       5. HOUSE HOLD VALIDATION
    ====================== */

    ELSEIF p_request_target = 'house_hold'
        AND (p_address IS NULL OR p_address = '') THEN
        SELECT 'Address is required for house hold request' AS msg;

    /* =====================
       6. INSERT REQUEST
    ====================== */

    ELSE
        INSERT INTO waste_request (
            full_name,
            phone,
            request_target,
            area_id,
            bin_id,
            address,
            status,
            schedule_id
        ) VALUES (
            p_full_name,
            p_phone,
            p_request_target,
            p_area_id,
            CASE WHEN p_request_target = 'bin' THEN p_bin_id ELSE NULL END,
            CASE WHEN p_request_target = 'house_hold' THEN p_address ELSE NULL END,
            'pending',
            NULL
        );

        SELECT 'Waste request submitted successfully' AS msg;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_waste_requestUpdated` (IN `p_full_name` VARCHAR(255), IN `p_phone` VARCHAR(50), IN `p_request_target` VARCHAR(50), IN `p_area_id` INT, IN `p_bin_id` INT, IN `p_address` VARCHAR(255))   BEGIN
    /* =====================
       1. BASIC VALIDATION
    ====================== */
    IF p_request_target IS NULL OR p_request_target = '' THEN
        SELECT 'Request type is required' AS msg;

    ELSEIF p_area_id IS NULL THEN
        SELECT 'Area is required' AS msg;

    ELSEIF (p_full_name IS NULL OR p_full_name = '')
        AND (p_phone IS NULL OR p_phone = '') THEN
        SELECT 'Full name or phone is required' AS msg;

    /* =====================
       2. VALID REQUEST TYPE
    ====================== */
    ELSEIF p_request_target NOT IN ('bin','house_hold') THEN
        SELECT 'Invalid request type' AS msg;

    /* =====================
       3. AREA EXISTS
    ====================== */
    ELSEIF NOT EXISTS (
        SELECT 1 FROM areas WHERE id = p_area_id
    ) THEN
        SELECT 'Selected area does not exist' AS msg;

    /* =====================
       4. BIN REQUEST VALIDATION
    ====================== */
    ELSEIF p_request_target = 'bin' AND p_bin_id IS NULL THEN
        SELECT 'Bin is required for bin request' AS msg;

    /* 🔒 Prevent duplicate active bin requests */
    ELSEIF p_request_target = 'bin'
        AND EXISTS (
            SELECT 1
            FROM waste_request
            WHERE bin_id = p_bin_id
              AND status IN ('pending','approved','assigned')
        ) THEN
        SELECT 'This bin already has an active request' AS msg;

    /* =====================
       5. HOUSE HOLD VALIDATION
    ====================== */
    ELSEIF p_request_target = 'house_hold'
        AND (p_address IS NULL OR p_address = '') THEN
        SELECT 'Address is required for house hold request' AS msg;

    /* =====================
       6. INSERT REQUEST
    ====================== */
    ELSE
        INSERT INTO waste_request (
            full_name,
            phone,
            request_target,
            area_id,
            bin_id,
            address,
            status,
            schedule_id
        ) VALUES (
            p_full_name,
            p_phone,
            p_request_target,
            p_area_id,
            CASE WHEN p_request_target = 'bin' THEN p_bin_id ELSE NULL END,
            CASE WHEN p_request_target = 'house_hold' THEN p_address ELSE NULL END,
            'pending',
            NULL
        );

        SELECT 'Waste request submitted successfully' AS msg;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_area` (IN `p_name` VARCHAR(100), IN `p_city` VARCHAR(100), IN `p_zone` VARCHAR(100))   BEGIN
    -- Required validations
    IF p_city IS NULL OR p_city = '' THEN
        SELECT 'City is required' AS msg;

    ELSEIF p_name IS NULL OR p_name = '' THEN
        SELECT 'Area name is required' AS msg;

    ELSEIF p_zone IS NULL OR p_zone = '' THEN
        SELECT 'Zone is required' AS msg;

    -- Duplicate check (REALISTIC)
    ELSEIF EXISTS (
        SELECT 1
        FROM areas
        WHERE city = p_city
          AND name = p_name
          AND zone = p_zone
    ) THEN
        SELECT 'This area already exists in the specified zone' AS msg;

    ELSE
        INSERT INTO areas (name, city, zone)
        VALUES (p_name, p_city, p_zone);

        -- Notify admins
        INSERT INTO notifications (user_id, message)
        SELECT u.id,
               CONCAT(
                   'New area added: ',
                   p_city, ' - ', p_name, ' (', p_zone, ')'
               )
        FROM users u
        JOIN roles r ON u.role_id = r.id
        WHERE r.name = 'admin';

        SELECT 'Area created successfully' AS msg;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_bin` (IN `p_bin_code` VARCHAR(50), IN `p_area_id` INT, IN `p_capacity_kg` INT)   BEGIN
    -- Validate bin code
    IF p_bin_code IS NULL OR p_bin_code = '' THEN
        SELECT 'Bin code is required' AS msg;

    -- Validate area
    ELSEIF NOT EXISTS (
        SELECT 1 FROM areas WHERE id = p_area_id
    ) THEN
        SELECT 'Invalid area' AS msg;

    -- Validate capacity
    ELSEIF p_capacity_kg IS NULL OR p_capacity_kg <= 0 THEN
        SELECT 'Invalid bin capacity' AS msg;

    -- Prevent duplicate bin
    ELSEIF EXISTS (
        SELECT 1 FROM bins WHERE bin_code = p_bin_code
    ) THEN
        SELECT 'Bin already exists' AS msg;

    ELSE
        -- Insert bin (defaults handle current_level_kg & status)
        INSERT INTO bins (
            bin_code,
            area_id,
            capacity_kg,
            updated_at
        )
        VALUES (
            p_bin_code,
            p_area_id,
            p_capacity_kg,
            NOW()
        );

        -- Notify ADMINS and SUPERVISORS
        INSERT INTO notifications (user_id, message)
        SELECT u.id,
               CONCAT(
                   'New bin added: ',
                   p_bin_code,
                   ' | Area: ',
                   a.name,
                   ' | Capacity: ',
                   p_capacity_kg,
                   'kg'
               )
        FROM users u
        JOIN roles r ON r.id = u.role_id
        JOIN areas a ON a.id = p_area_id
        WHERE r.name IN ('admin', 'supervisor');

        SELECT 'Bin added successfully' AS msg;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_role` (IN `p_name` VARCHAR(50), IN `p_description` VARCHAR(100))   BEGIN
    -- Validate role name
    IF p_name IS NULL OR p_name = '' THEN
        SELECT 'Role name is required' AS msg;

    -- Check duplicate
    ELSEIF EXISTS (SELECT 1 FROM roles WHERE name = p_name) THEN
        SELECT 'Role already exists' AS msg;

    ELSE
        -- Insert role
        INSERT INTO roles (name, description)
        VALUES (p_name, p_description);

        -- Notify admins
        INSERT INTO notifications (user_id, message)
        SELECT u.id,
               CONCAT('New role created: ', p_name)
        FROM users u
        JOIN roles r ON u.role_id = r.id
        WHERE r.name = 'admin';

        SELECT 'Role created successfully' AS msg;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_insert_user` (IN `p_role_id` INT, IN `p_full_name` VARCHAR(100), IN `p_email` VARCHAR(100), IN `p_phone` VARCHAR(20), IN `p_password` VARCHAR(255), IN `p_area_id` INT)   BEGIN
    IF p_full_name IS NULL OR p_full_name = '' THEN
        SELECT 'Full name is required' AS msg;

    ELSEIF p_email IS NULL OR p_email = '' THEN
        SELECT 'Email is required' AS msg;

    ELSEIF p_password IS NULL OR p_password = '' THEN
        SELECT 'Password is required' AS msg;

    ELSEIF NOT EXISTS (SELECT 1 FROM roles WHERE id = p_role_id) THEN
        SELECT 'Invalid role' AS msg;

    ELSEIF p_area_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM areas WHERE id = p_area_id
    ) THEN
        SELECT 'Invalid area' AS msg;

    ELSEIF EXISTS (SELECT 1 FROM users WHERE email = p_email) THEN
        SELECT 'Email already exists' AS msg;

    ELSE
        INSERT INTO users (
            role_id, full_name, email, phone, password, area_id
        )
        VALUES (
            p_role_id, p_full_name, p_email, p_phone, p_password, p_area_id
        );

        -- Notify the new user
        INSERT INTO notifications (user_id, message)
        SELECT u.id,
               CONCAT('Welcome ', u.full_name, '! Your account has been created.')
        FROM users u
        WHERE u.email = p_email;

        -- Notify all admins
        INSERT INTO notifications (user_id, message)
        SELECT u.id,
               CONCAT('New user created: ', p_full_name, ' (Role: ', r.name, ')')
        FROM users u
        JOIN roles r ON u.role_id = r.id
        WHERE r.name = 'admin';

        SELECT 'User created successfully, notifications sent' AS msg;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login` (IN `p_email` VARCHAR(100), IN `p_password` VARCHAR(255))   BEGIN

    -- Check if email + password exists
    IF EXISTS (
        SELECT 1 FROM users
        WHERE email = p_email
          AND password = MD5(p_password)
    ) THEN

        -- Check if user is active
        IF EXISTS (
            SELECT 1 FROM users
            WHERE email = p_email
              AND status = 'active'
        ) THEN

            -- ADMIN
            IF EXISTS (
                SELECT 1
                FROM users u
                JOIN roles r ON u.role_id = r.id
                WHERE u.email = p_email
                  AND u.password = MD5(p_password)
                  AND r.name = 'admin'
            ) THEN
                SELECT
                    u.*,
                    r.name AS role,
                    'admin' AS msg
                FROM users u
                JOIN roles r ON u.role_id = r.id
                WHERE u.email = p_email
                  AND u.password = MD5(p_password);

            -- DRIVER
            ELSEIF EXISTS (
                SELECT 1
                FROM users u
                JOIN roles r ON u.role_id = r.id
                WHERE u.email = p_email
                  AND u.password = MD5(p_password)
                  AND r.name = 'driver'
            ) THEN
                SELECT
                    u.*,
                    r.name AS role,
                    'driver' AS msg
                FROM users u
                JOIN roles r ON u.role_id = r.id
                WHERE u.email = p_email
                  AND u.password = MD5(p_password);

            -- SUPERVISOR
            ELSEIF EXISTS (
                SELECT 1
                FROM users u
                JOIN roles r ON u.role_id = r.id
                WHERE u.email = p_email
                  AND u.password = MD5(p_password)
                  AND r.name = 'supervisor'
            ) THEN
                SELECT
                    u.*,
                    r.name AS role,
                    'supervisor' AS msg
                FROM users u
                JOIN roles r ON u.role_id = r.id
                WHERE u.email = p_email
                  AND u.password = MD5(p_password);

            -- Any other role → deny
            ELSE
                SELECT 'Deny' AS msg;
            END IF;

        ELSE
            -- Inactive account
            SELECT 'Locked' AS msg;
        END IF;

    ELSE
        -- Wrong email or password
        SELECT 'Deny' AS msg;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_start_collection_schedule` (IN `p_schedule_id` INT, IN `p_driver_id` INT)   BEGIN
    DECLARE v_area_id INT;
    DECLARE v_collection_date DATE;

    /* =========================
       1. SCHEDULE EXISTENCE
    ========================= */

    IF NOT EXISTS (
        SELECT 1
        FROM collection_schedule
        WHERE id = p_schedule_id
    ) THEN
        SELECT 'Schedule not found' AS msg;

    /* =========================
       2. DRIVER OWNERSHIP
    ========================= */

    ELSEIF NOT EXISTS (
        SELECT 1
        FROM collection_schedule
        WHERE id = p_schedule_id
          AND driver_id = p_driver_id
    ) THEN
        SELECT 'This schedule is not assigned to you' AS msg;

    /* =========================
       3. STATUS CHECK
    ========================= */

    ELSEIF NOT EXISTS (
        SELECT 1
        FROM collection_schedule
        WHERE id = p_schedule_id
          AND status = 'scheduled'
    ) THEN
        SELECT 'Schedule already started or completed' AS msg;

    /* =========================
       4. START COLLECTION
    ========================= */

    ELSE
        /* Get data for notifications */
        SELECT area_id, collection_date
        INTO v_area_id, v_collection_date
        FROM collection_schedule
        WHERE id = p_schedule_id;

        /* Update schedule */
        UPDATE collection_schedule
        SET
            status = 'in_progress',
            started_at = NOW()
        WHERE id = p_schedule_id;

        /* Notify driver */
        INSERT INTO notifications (user_id, message)
        VALUES (
            p_driver_id,
            CONCAT(
                'Collection started for area ID ',
                v_area_id,
                ' scheduled on ',
                v_collection_date
            )
        );

        /* Notify admins & supervisors */
        INSERT INTO notifications (user_id, message)
        SELECT u.id,
               CONCAT(
                   'Driver ID ',
                   p_driver_id,
                   ' started collection for area ID ',
                   v_area_id,
                   ' (schedule ID ',
                   p_schedule_id,
                   ').'
               )
        FROM users u
        JOIN roles r ON r.id = u.role_id
        WHERE r.name IN ('admin','supervisor');

        /* Success */
        SELECT 'Collection started successfully' AS msg;

    END IF;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `areas`
--

CREATE TABLE `areas` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `city` varchar(100) DEFAULT NULL,
  `zone` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `areas`
--

INSERT INTO `areas` (`id`, `name`, `city`, `zone`, `created_at`) VALUES
(1, 'waberi', 'mogadishu', 'KPP', '2026-01-19 04:11:21'),
(3, 'Hodon', 'Mogadishu', 'KBB', '2026-02-06 03:44:34'),
(7, 'Hodon', 'Mogadishu', 'Bakara', '2026-03-10 08:44:13'),
(8, 'Hodon', 'Mogadishu', 'biyamalow', '2026-03-10 08:44:27'),
(9, 'Hodon', 'Mogadishu', 'Taleh', '2026-03-10 08:44:41');

-- --------------------------------------------------------

--
-- Table structure for table `bins`
--

CREATE TABLE `bins` (
  `id` int(11) NOT NULL,
  `bin_code` varchar(50) NOT NULL,
  `area_id` int(11) NOT NULL,
  `capacity_kg` int(11) NOT NULL,
  `current_level_kg` int(11) DEFAULT 0 CHECK (`current_level_kg` <= `capacity_kg`),
  `status` varchar(200) DEFAULT 'empty',
  `last_collected_at` datetime DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bins`
--

INSERT INTO `bins` (`id`, `bin_code`, `area_id`, `capacity_kg`, `current_level_kg`, `status`, `last_collected_at`, `updated_at`) VALUES
(4, 'HD001', 3, 500, 0, 'empty', '2026-03-12 14:36:36', '2026-03-12 11:36:36'),
(5, 'WB002', 1, 600, 0, 'full', '2026-03-11 11:45:56', '2026-03-11 08:45:56'),
(10, 'HD002', 8, 5000, 0, 'full', NULL, '2026-03-10 13:53:54'),
(12, 'WB003', 1, 5678, 0, 'empty', '2026-03-12 12:59:22', '2026-03-12 09:59:22');

-- --------------------------------------------------------

--
-- Table structure for table `collection_logs`
--

CREATE TABLE `collection_logs` (
  `id` int(11) NOT NULL,
  `schedule_id` int(11) NOT NULL,
  `bin_id` int(11) DEFAULT NULL,
  `request_id` int(11) DEFAULT NULL,
  `collected_weight_kg` int(11) NOT NULL,
  `collected_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `collection_logs`
--

INSERT INTO `collection_logs` (`id`, `schedule_id`, `bin_id`, `request_id`, `collected_weight_kg`, `collected_at`) VALUES
(5, 5, 5, 6, 0, '2026-02-16 21:40:48'),
(6, 4, 4, 5, 0, '2026-02-16 22:23:29'),
(7, 8, 5, 8, 0, '2026-02-17 06:17:32'),
(8, 9, 5, 9, 0, '2026-02-17 07:01:18'),
(9, 10, 4, 10, 0, '2026-02-17 07:01:58'),
(10, 12, 4, 12, 0, '2026-02-17 07:07:43'),
(11, 11, 5, 11, 0, '2026-02-17 07:08:03'),
(12, 15, 4, 14, 0, '2026-02-17 07:25:49'),
(13, 14, 5, 13, 0, '2026-02-17 07:26:28'),
(14, 16, 5, 15, 0, '2026-02-17 07:33:12'),
(15, 17, 4, 16, 0, '2026-02-17 07:36:15'),
(16, 18, 5, 17, 0, '2026-02-17 07:38:01'),
(17, 20, 4, 18, 0, '2026-02-17 07:38:56'),
(18, 21, 5, 19, 0, '2026-02-17 07:41:05'),
(19, 22, 4, 20, 0, '2026-02-17 07:41:31'),
(20, 24, 4, 22, 0, '2026-02-17 07:44:15'),
(21, 23, 5, 21, 0, '2026-02-17 07:44:28'),
(22, 26, 5, 23, 0, '2026-02-22 03:14:45'),
(23, 27, 4, 24, 0, '2026-02-22 03:15:37'),
(24, 28, 5, 25, 0, '2026-02-22 03:26:33'),
(25, 29, 4, 26, 0, '2026-02-22 03:29:33'),
(26, 31, 4, 28, 0, '2026-02-22 03:38:42'),
(27, 30, 5, 27, 0, '2026-02-22 03:38:56'),
(28, 32, 5, 29, 0, '2026-02-23 16:57:27'),
(29, 34, 4, 31, 0, '2026-02-23 16:57:50'),
(30, 38, 5, 36, 0, '2026-02-24 00:13:46'),
(31, 35, NULL, 30, 0, '2026-02-24 03:34:57'),
(32, 35, NULL, 30, 0, '2026-02-24 03:37:23'),
(33, 33, NULL, 32, 0, '2026-02-24 03:44:23'),
(34, 37, NULL, 35, 0, '2026-02-24 03:49:02'),
(35, 39, 5, 38, 0, '2026-02-24 03:53:34'),
(36, 36, NULL, 33, 0, '2026-02-24 04:21:20'),
(37, 40, 5, 39, 0, '2026-02-24 04:37:20'),
(38, 43, NULL, 40, 0, '2026-02-24 04:39:47'),
(39, 44, NULL, 41, 0, '2026-02-24 04:45:12'),
(40, 45, NULL, 42, 0, '2026-02-24 04:45:34'),
(41, 41, 4, 37, 0, '2026-02-24 04:47:50'),
(42, 46, 5, 43, 0, '2026-02-24 04:47:57'),
(43, 48, 4, 44, 0, '2026-02-24 05:16:59'),
(44, 47, NULL, 45, 0, '2026-02-24 05:17:22'),
(45, 49, 5, 46, 0, '2026-02-25 14:21:21'),
(46, 50, NULL, 47, 0, '2026-02-25 14:21:34'),
(47, 51, 5, 49, 0, '2026-02-25 15:44:21'),
(48, 52, 5, 53, 0, '2026-03-11 11:45:56'),
(49, 53, 4, 66, 0, '2026-03-12 12:49:35'),
(50, 58, 12, 68, 0, '2026-03-12 12:59:22'),
(51, 57, 4, 67, 0, '2026-03-12 14:36:36');

-- --------------------------------------------------------

--
-- Table structure for table `collection_schedule`
--

CREATE TABLE `collection_schedule` (
  `id` int(11) NOT NULL,
  `area_id` int(11) NOT NULL,
  `vehicle_id` int(11) NOT NULL,
  `driver_id` int(11) NOT NULL,
  `collection_date` date NOT NULL,
  `started_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `status` varchar(200) DEFAULT 'scheduled',
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `collection_schedule`
--

INSERT INTO `collection_schedule` (`id`, `area_id`, `vehicle_id`, `driver_id`, `collection_date`, `started_at`, `completed_at`, `status`, `created_by`, `created_at`) VALUES
(3, 1, 3, 2, '2026-02-13', '2026-02-16 20:00:25', '2026-02-17 05:44:30', 'completed', 1, '2026-02-06 04:10:41'),
(4, 3, 4, 2, '2026-02-12', '2026-02-16 19:59:15', '2026-02-17 06:11:03', 'completed', 1, '2026-02-06 04:22:44'),
(5, 1, 5, 2, '2026-02-14', '2026-02-16 20:24:00', '2026-02-17 05:36:53', 'completed', 1, '2026-02-14 13:44:48'),
(6, 1, 5, 2, '2026-02-14', '2026-02-17 06:01:11', '2026-02-17 06:04:10', 'completed', 1, '2026-02-14 13:44:48'),
(7, 1, 6, 2, '2026-02-20', '2026-02-16 20:35:17', '2026-02-17 06:10:07', 'completed', 1, '2026-02-16 17:33:50'),
(8, 1, 5, 2, '2026-02-17', '2026-02-17 06:17:23', '2026-02-17 06:51:21', 'completed', 1, '2026-02-17 03:16:36'),
(9, 1, 4, 2, '2026-02-20', '2026-02-17 07:01:14', '2026-02-17 07:01:28', 'completed', 1, '2026-02-17 04:00:08'),
(10, 3, 3, 2, '2026-02-27', '2026-02-17 07:01:48', '2026-02-17 07:02:28', 'completed', 1, '2026-02-17 04:00:25'),
(11, 1, 5, 2, '2026-02-27', '2026-02-17 07:08:01', '2026-02-17 07:09:30', 'completed', 1, '2026-02-17 04:05:16'),
(12, 3, 3, 2, '2026-02-20', '2026-02-17 07:06:16', '2026-02-17 07:09:41', 'completed', 1, '2026-02-17 04:05:31'),
(13, 3, 3, 2, '2026-02-20', '2026-02-17 07:09:52', '2026-02-17 07:09:56', 'completed', 1, '2026-02-17 04:05:31'),
(14, 1, 4, 2, '2026-02-28', '2026-02-17 07:26:14', '2026-02-17 07:26:30', 'completed', 1, '2026-02-17 04:20:23'),
(15, 3, 5, 2, '2026-02-20', '2026-02-17 07:25:34', '2026-02-17 07:25:51', 'completed', 1, '2026-02-17 04:20:44'),
(16, 1, 3, 2, '2026-02-17', '2026-02-17 07:32:59', '2026-02-17 07:33:15', 'completed', 1, '2026-02-17 04:32:16'),
(17, 3, 5, 2, '2026-02-19', '2026-02-17 07:33:37', '2026-02-17 07:36:17', 'completed', 1, '2026-02-17 04:32:44'),
(18, 1, 3, 2, '2026-02-17', '2026-02-17 07:37:51', '2026-02-17 07:38:03', 'completed', 1, '2026-02-17 04:37:11'),
(19, 3, 4, 2, '2026-02-18', '2026-02-17 07:38:13', '2026-02-17 07:39:05', 'completed', 1, '2026-02-17 04:37:37'),
(20, 3, 4, 2, '2026-02-18', '2026-02-17 07:38:53', '2026-02-17 07:38:58', 'completed', 1, '2026-02-17 04:37:37'),
(21, 1, 5, 2, '2026-02-17', '2026-02-17 07:40:56', '2026-02-17 07:41:08', 'completed', 1, '2026-02-17 04:40:03'),
(22, 3, 4, 2, '2026-02-26', '2026-02-17 07:41:24', '2026-02-17 07:41:33', 'completed', 1, '2026-02-17 04:40:42'),
(23, 1, 4, 2, '2026-02-17', '2026-02-17 07:43:44', '2026-02-17 07:44:31', 'completed', 1, '2026-02-17 04:43:10'),
(24, 3, 3, 2, '2026-02-26', '2026-02-17 07:44:11', '2026-02-17 07:44:17', 'completed', 1, '2026-02-17 04:43:29'),
(25, 3, 3, 2, '2026-02-26', '2026-02-17 07:44:42', '2026-02-17 07:44:46', 'completed', 1, '2026-02-17 04:43:29'),
(26, 1, 4, 2, '2026-02-22', '2026-02-22 03:14:29', '2026-02-22 03:14:56', 'completed', 1, '2026-02-22 00:11:08'),
(27, 3, 6, 2, '2026-03-03', '2026-02-22 03:15:13', '2026-02-22 03:15:42', 'completed', 1, '2026-02-22 00:11:38'),
(28, 1, 4, 2, '2026-02-22', '2026-02-22 03:25:49', '2026-02-22 03:26:38', 'completed', 1, '2026-02-22 00:24:47'),
(29, 3, 3, 2, '2026-02-28', '2026-02-22 03:26:47', '2026-02-22 03:29:35', 'completed', 1, '2026-02-22 00:25:30'),
(30, 1, 5, 2, '2026-02-22', '2026-02-22 03:37:47', '2026-02-22 03:38:57', 'completed', 1, '2026-02-22 00:37:13'),
(31, 3, 4, 2, '2026-02-28', '2026-02-22 03:38:24', '2026-02-22 03:38:44', 'completed', 1, '2026-02-22 00:37:32'),
(32, 1, 5, 2, '2026-02-22', '2026-02-23 16:57:25', '2026-02-23 16:57:29', 'completed', 1, '2026-02-22 01:23:52'),
(33, 1, 6, 2, '2026-02-23', '2026-02-24 02:28:02', '2026-02-24 04:20:25', 'completed', 1, '2026-02-23 13:08:05'),
(34, 3, 3, 2, '2026-02-27', '2026-02-23 16:57:48', '2026-02-23 16:57:52', 'completed', 1, '2026-02-23 13:19:06'),
(35, 3, 4, 2, '2026-02-24', '2026-02-24 02:30:15', '2026-02-24 04:21:06', 'completed', 1, '2026-02-23 13:32:39'),
(36, 3, 5, 2, '2026-02-25', '2026-02-24 04:20:58', '2026-02-24 04:21:25', 'completed', 1, '2026-02-23 14:20:03'),
(37, 1, 3, 2, '2026-03-14', '2026-02-24 03:48:36', '2026-02-24 04:21:29', 'completed', 1, '2026-02-23 14:20:43'),
(38, 1, 7, 2, '2026-02-27', '2026-02-24 00:13:34', '2026-02-24 00:13:50', 'completed', 1, '2026-02-23 20:48:56'),
(39, 1, 7, 2, '2026-02-28', '2026-02-24 03:53:30', '2026-02-24 04:03:26', 'completed', 1, '2026-02-23 22:59:46'),
(40, 1, 3, 2, '2026-02-24', '2026-02-24 04:37:14', '2026-02-24 04:37:22', 'completed', 1, '2026-02-24 01:33:58'),
(41, 3, 5, 2, '2026-02-27', '2026-02-24 04:47:48', '2026-02-24 04:47:52', 'completed', 1, '2026-02-24 01:34:10'),
(42, 3, 6, 2, '2026-02-28', '2026-02-24 04:38:07', '2026-02-24 04:38:10', 'completed', 1, '2026-02-24 01:34:39'),
(43, 3, 7, 2, '2026-03-07', '2026-02-24 04:39:20', '2026-02-24 04:39:50', 'completed', 1, '2026-02-24 01:34:59'),
(44, 1, 3, 2, '2026-02-24', '2026-02-24 04:44:50', '2026-02-24 04:45:14', 'completed', 1, '2026-02-24 01:44:17'),
(45, 1, 6, 2, '2026-02-28', '2026-02-24 04:45:27', '2026-02-24 04:45:50', 'completed', 1, '2026-02-24 01:44:28'),
(46, 1, 3, 2, '2026-02-28', '2026-02-24 04:47:55', '2026-02-24 04:47:59', 'completed', 1, '2026-02-24 01:47:13'),
(47, 1, 3, 2, '2026-02-28', '2026-02-24 05:17:18', '2026-02-24 05:17:25', 'completed', 1, '2026-02-24 02:12:32'),
(48, 3, 5, 2, '2026-02-27', '2026-02-24 05:16:53', '2026-02-24 05:17:02', 'completed', 1, '2026-02-24 02:12:49'),
(49, 1, 4, 2, '2026-02-28', '2026-02-25 14:21:19', '2026-02-25 14:21:23', 'completed', 1, '2026-02-25 07:19:46'),
(50, 3, 6, 2, '2026-02-26', '2026-02-25 14:21:29', '2026-02-25 14:21:35', 'completed', 1, '2026-02-25 07:20:27'),
(51, 1, 4, 2, '2026-02-27', '2026-02-25 15:44:19', '2026-02-25 15:44:24', 'completed', 1, '2026-02-25 12:35:09'),
(52, 1, 7, 2, '2026-03-18', '2026-03-09 15:42:32', '2026-03-11 11:46:00', 'completed', 1, '2026-03-09 12:40:50'),
(53, 3, 1, 2, '2026-03-11', '2026-03-12 12:48:40', '2026-03-12 12:49:40', 'completed', 1, '2026-03-11 11:11:36'),
(54, 3, 2, 2, '2026-04-25', NULL, NULL, 'scheduled', 1, '2026-03-11 11:34:52'),
(55, 1, 3, 2, '2026-04-21', NULL, NULL, 'scheduled', 1, '2026-03-11 11:39:55'),
(56, 1, 7, 5, '2026-04-28', NULL, NULL, 'scheduled', 1, '2026-03-12 09:13:00'),
(57, 3, 9, 4, '2026-03-31', '2026-03-12 14:36:34', '2026-03-12 14:36:38', 'completed', 1, '2026-03-12 09:55:46'),
(58, 1, 1, 2, '2026-03-13', '2026-03-12 12:59:20', '2026-03-12 12:59:24', 'completed', 1, '2026-03-12 09:58:53');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `message`, `is_read`, `created_at`) VALUES
(1, 1, 'Welcome Abdikadir Mohamed! Your account has been created.', 0, '2026-02-06 03:49:24'),
(2, 1, 'New user created: Abdikadir Mohamed (Role: admin)', 0, '2026-02-06 03:49:24'),
(3, 2, 'Welcome najka Abdi! Your account has been created.', 0, '2026-02-06 03:49:58'),
(4, 1, 'New user created: najka Abdi (Role: admin)', 0, '2026-02-06 03:49:58'),
(5, 3, 'Welcome geedi raage ali! Your account has been created.', 0, '2026-02-06 03:50:43'),
(6, 1, 'New user created: geedi raage ali (Role: admin)', 0, '2026-02-06 03:50:43'),
(7, 1, 'New bin added: Bd001 | Area: waberi | Capacity: 5000kg', 0, '2026-02-06 03:52:12'),
(8, 3, 'New bin added: Bd001 | Area: waberi | Capacity: 5000kg', 0, '2026-02-06 03:52:12'),
(10, 1, 'New bin added: hd001 | Area: waberi | Capacity: 500kg', 0, '2026-02-06 03:52:28'),
(11, 3, 'New bin added: hd001 | Area: waberi | Capacity: 500kg', 0, '2026-02-06 03:52:28'),
(13, 1, 'New bin added: hd00144 | Area: Hodon | Capacity: 55kg', 0, '2026-02-06 03:52:56'),
(14, 3, 'New bin added: hd00144 | Area: Hodon | Capacity: 55kg', 0, '2026-02-06 03:52:56'),
(16, 1, 'New vehicle added: 001 | Capacity: 5000 kg. Ready for assignment.', 0, '2026-02-06 03:54:01'),
(17, 3, 'New vehicle added: 001 | Capacity: 5000 kg. Ready for assignment.', 0, '2026-02-06 03:54:01'),
(19, 1, 'New vehicle added: 002 | Capacity: 2000 kg. Ready for assignment.', 0, '2026-02-06 03:54:09'),
(20, 3, 'New vehicle added: 002 | Capacity: 2000 kg. Ready for assignment.', 0, '2026-02-06 03:54:09'),
(22, 1, 'New vehicle added: 005 | Capacity: 6000 kg. Ready for assignment.', 0, '2026-02-06 03:54:16'),
(23, 3, 'New vehicle added: 005 | Capacity: 6000 kg. Ready for assignment.', 0, '2026-02-06 03:54:16'),
(25, 2, 'You have been assigned a collection task on 2026-02-20 for area ID 1', 0, '2026-02-06 04:00:01'),
(26, 1, 'New collection schedule created for area ID 1 on 2026-02-20. Vehicle ID 2 assigned.', 0, '2026-02-06 04:00:01'),
(27, 3, 'New collection schedule created for area ID 1 on 2026-02-20. Vehicle ID 2 assigned.', 0, '2026-02-06 04:00:01'),
(29, 1, 'New bin added: HD001 | Area: waberi | Capacity: 500kg', 0, '2026-02-06 04:04:37'),
(30, 3, 'New bin added: HD001 | Area: waberi | Capacity: 500kg', 0, '2026-02-06 04:04:37'),
(32, 1, 'New bin added: WB002 | Area: waberi | Capacity: 600kg', 0, '2026-02-06 04:04:49'),
(33, 3, 'New bin added: WB002 | Area: waberi | Capacity: 600kg', 0, '2026-02-06 04:04:49'),
(35, 1, 'New vehicle added: 004 | Capacity: 5500 kg. Ready for assignment.', 0, '2026-02-06 04:22:00'),
(36, 3, 'New vehicle added: 004 | Capacity: 5500 kg. Ready for assignment.', 0, '2026-02-06 04:22:00'),
(38, 1, 'New vehicle added: 006 | Capacity: 556 kg. Ready for assignment.', 0, '2026-02-06 04:24:24'),
(39, 3, 'New vehicle added: 006 | Capacity: 556 kg. Ready for assignment.', 0, '2026-02-06 04:24:24'),
(40, 2, 'Collection started for area ID 3 scheduled on 2026-02-12', 0, '2026-02-16 16:59:15'),
(41, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 4).', 0, '2026-02-16 16:59:15'),
(42, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 4).', 0, '2026-02-16 16:59:15'),
(44, 2, 'Collection started for area ID 1 scheduled on 2026-02-13', 0, '2026-02-16 17:00:25'),
(45, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 3).', 0, '2026-02-16 17:00:25'),
(46, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 3).', 0, '2026-02-16 17:00:25'),
(48, 2, 'Collection started for area ID 1 scheduled on 2026-02-14', 0, '2026-02-16 17:24:00'),
(49, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 5).', 0, '2026-02-16 17:24:00'),
(50, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 5).', 0, '2026-02-16 17:24:00'),
(52, 1, 'New vehicle added: 007 | Capacity: 7787 kg. Ready for assignment.', 0, '2026-02-16 17:33:32'),
(53, 3, 'New vehicle added: 007 | Capacity: 7787 kg. Ready for assignment.', 0, '2026-02-16 17:33:32'),
(55, 2, 'Collection started for area ID 1 scheduled on 2026-02-20', 0, '2026-02-16 17:35:17'),
(56, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 7).', 0, '2026-02-16 17:35:17'),
(57, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 7).', 0, '2026-02-16 17:35:17'),
(59, 2, 'Collection started for area ID 1 scheduled on 2026-02-14', 0, '2026-02-17 03:01:11'),
(60, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 6).', 0, '2026-02-17 03:01:11'),
(61, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 6).', 0, '2026-02-17 03:01:11'),
(63, 2, 'Collection started for area ID 1 scheduled on 2026-02-17', 0, '2026-02-17 03:17:23'),
(64, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 8).', 0, '2026-02-17 03:17:23'),
(65, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 8).', 0, '2026-02-17 03:17:23'),
(67, 2, 'Collection started for area ID 1 scheduled on 2026-02-20', 0, '2026-02-17 04:01:14'),
(68, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 9).', 0, '2026-02-17 04:01:14'),
(69, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 9).', 0, '2026-02-17 04:01:14'),
(71, 2, 'Collection started for area ID 3 scheduled on 2026-02-27', 0, '2026-02-17 04:01:48'),
(72, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 10).', 0, '2026-02-17 04:01:48'),
(73, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 10).', 0, '2026-02-17 04:01:48'),
(75, 2, 'Collection started for area ID 3 scheduled on 2026-02-20', 0, '2026-02-17 04:06:16'),
(76, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 12).', 0, '2026-02-17 04:06:16'),
(77, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 12).', 0, '2026-02-17 04:06:16'),
(79, 2, 'Collection started for area ID 1 scheduled on 2026-02-27', 0, '2026-02-17 04:08:01'),
(80, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 11).', 0, '2026-02-17 04:08:01'),
(81, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 11).', 0, '2026-02-17 04:08:01'),
(83, 2, 'Collection started for area ID 3 scheduled on 2026-02-20', 0, '2026-02-17 04:09:52'),
(84, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 13).', 0, '2026-02-17 04:09:52'),
(85, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 13).', 0, '2026-02-17 04:09:52'),
(87, 2, 'Collection started for area ID 3 scheduled on 2026-02-20', 0, '2026-02-17 04:25:34'),
(88, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 15).', 0, '2026-02-17 04:25:34'),
(89, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 15).', 0, '2026-02-17 04:25:34'),
(91, 2, 'Collection started for area ID 1 scheduled on 2026-02-28', 0, '2026-02-17 04:26:14'),
(92, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 14).', 0, '2026-02-17 04:26:14'),
(93, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 14).', 0, '2026-02-17 04:26:14'),
(95, 2, 'Collection started for area ID 1 scheduled on 2026-02-17', 0, '2026-02-17 04:32:59'),
(96, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 16).', 0, '2026-02-17 04:32:59'),
(97, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 16).', 0, '2026-02-17 04:32:59'),
(99, 2, 'Collection started for area ID 3 scheduled on 2026-02-19', 0, '2026-02-17 04:33:37'),
(100, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 17).', 0, '2026-02-17 04:33:37'),
(101, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 17).', 0, '2026-02-17 04:33:37'),
(103, 2, 'Collection started for area ID 1 scheduled on 2026-02-17', 0, '2026-02-17 04:37:51'),
(104, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 18).', 0, '2026-02-17 04:37:51'),
(105, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 18).', 0, '2026-02-17 04:37:51'),
(107, 2, 'Collection started for area ID 3 scheduled on 2026-02-18', 0, '2026-02-17 04:38:13'),
(108, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 19).', 0, '2026-02-17 04:38:13'),
(109, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 19).', 0, '2026-02-17 04:38:13'),
(111, 2, 'Collection started for area ID 3 scheduled on 2026-02-18', 0, '2026-02-17 04:38:53'),
(112, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 20).', 0, '2026-02-17 04:38:53'),
(113, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 20).', 0, '2026-02-17 04:38:53'),
(115, 2, 'Collection started for area ID 1 scheduled on 2026-02-17', 0, '2026-02-17 04:40:56'),
(116, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 21).', 0, '2026-02-17 04:40:56'),
(117, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 21).', 0, '2026-02-17 04:40:56'),
(119, 2, 'Collection started for area ID 3 scheduled on 2026-02-26', 0, '2026-02-17 04:41:24'),
(120, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 22).', 0, '2026-02-17 04:41:24'),
(121, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 22).', 0, '2026-02-17 04:41:24'),
(123, 2, 'Collection started for area ID 1 scheduled on 2026-02-17', 0, '2026-02-17 04:43:44'),
(124, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 23).', 0, '2026-02-17 04:43:44'),
(125, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 23).', 0, '2026-02-17 04:43:44'),
(127, 2, 'Collection started for area ID 3 scheduled on 2026-02-26', 0, '2026-02-17 04:44:11'),
(128, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 24).', 0, '2026-02-17 04:44:11'),
(129, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 24).', 0, '2026-02-17 04:44:11'),
(131, 2, 'Collection started for area ID 3 scheduled on 2026-02-26', 0, '2026-02-17 04:44:42'),
(132, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 25).', 0, '2026-02-17 04:44:42'),
(133, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 25).', 0, '2026-02-17 04:44:42'),
(135, 2, 'Collection started for area ID 1 scheduled on 2026-02-22', 0, '2026-02-22 00:14:29'),
(136, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 26).', 0, '2026-02-22 00:14:29'),
(137, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 26).', 0, '2026-02-22 00:14:29'),
(139, 2, 'Collection started for area ID 3 scheduled on 2026-03-03', 0, '2026-02-22 00:15:13'),
(140, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 27).', 0, '2026-02-22 00:15:13'),
(141, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 27).', 0, '2026-02-22 00:15:13'),
(143, 2, 'Collection started for area ID 1 scheduled on 2026-02-22', 0, '2026-02-22 00:25:49'),
(144, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 28).', 0, '2026-02-22 00:25:49'),
(145, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 28).', 0, '2026-02-22 00:25:49'),
(147, 2, 'Collection started for area ID 3 scheduled on 2026-02-28', 0, '2026-02-22 00:26:47'),
(148, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 29).', 0, '2026-02-22 00:26:47'),
(149, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 29).', 0, '2026-02-22 00:26:47'),
(151, 2, 'Collection started for area ID 1 scheduled on 2026-02-22', 0, '2026-02-22 00:37:47'),
(152, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 30).', 0, '2026-02-22 00:37:47'),
(153, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 30).', 0, '2026-02-22 00:37:47'),
(155, 2, 'Collection started for area ID 3 scheduled on 2026-02-28', 0, '2026-02-22 00:38:24'),
(156, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 31).', 0, '2026-02-22 00:38:24'),
(157, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 31).', 0, '2026-02-22 00:38:24'),
(159, 2, 'Collection started for area ID 1 scheduled on 2026-02-22', 0, '2026-02-23 13:57:25'),
(160, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 32).', 0, '2026-02-23 13:57:25'),
(161, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 32).', 0, '2026-02-23 13:57:25'),
(163, 2, 'Collection started for area ID 3 scheduled on 2026-02-27', 0, '2026-02-23 13:57:48'),
(164, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 34).', 0, '2026-02-23 13:57:48'),
(165, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 34).', 0, '2026-02-23 13:57:48'),
(167, 2, 'Collection started for area ID 1 scheduled on 2026-02-27', 0, '2026-02-23 21:13:34'),
(168, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 38).', 0, '2026-02-23 21:13:34'),
(169, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 38).', 0, '2026-02-23 21:13:34'),
(171, 2, 'Collection started for area ID 1 scheduled on 2026-02-23', 0, '2026-02-23 23:28:02'),
(172, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 33).', 0, '2026-02-23 23:28:02'),
(173, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 33).', 0, '2026-02-23 23:28:02'),
(175, 2, 'Collection started for area ID 3 scheduled on 2026-02-24', 0, '2026-02-23 23:30:15'),
(176, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 35).', 0, '2026-02-23 23:30:15'),
(177, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 35).', 0, '2026-02-23 23:30:15'),
(179, 2, 'Collection started for area ID 1 scheduled on 2026-03-14', 0, '2026-02-24 00:48:36'),
(180, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 37).', 0, '2026-02-24 00:48:36'),
(181, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 37).', 0, '2026-02-24 00:48:36'),
(183, 2, 'Collection started for area ID 1 scheduled on 2026-02-28', 0, '2026-02-24 00:53:30'),
(184, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 39).', 0, '2026-02-24 00:53:30'),
(185, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 39).', 0, '2026-02-24 00:53:30'),
(187, 2, 'Collection started for area ID 3 scheduled on 2026-02-25', 0, '2026-02-24 01:20:58'),
(188, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 36).', 0, '2026-02-24 01:20:58'),
(189, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 36).', 0, '2026-02-24 01:20:58'),
(191, 2, 'Collection started for area ID 1 scheduled on 2026-02-24', 0, '2026-02-24 01:37:14'),
(192, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 40).', 0, '2026-02-24 01:37:14'),
(193, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 40).', 0, '2026-02-24 01:37:14'),
(195, 2, 'Collection started for area ID 3 scheduled on 2026-02-28', 0, '2026-02-24 01:38:07'),
(196, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 42).', 0, '2026-02-24 01:38:07'),
(197, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 42).', 0, '2026-02-24 01:38:07'),
(199, 2, 'Collection started for area ID 3 scheduled on 2026-03-07', 0, '2026-02-24 01:39:20'),
(200, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 43).', 0, '2026-02-24 01:39:20'),
(201, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 43).', 0, '2026-02-24 01:39:20'),
(203, 2, 'Collection started for area ID 1 scheduled on 2026-02-24', 0, '2026-02-24 01:44:50'),
(204, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 44).', 0, '2026-02-24 01:44:50'),
(205, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 44).', 0, '2026-02-24 01:44:50'),
(207, 2, 'Collection started for area ID 1 scheduled on 2026-02-28', 0, '2026-02-24 01:45:27'),
(208, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 45).', 0, '2026-02-24 01:45:27'),
(209, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 45).', 0, '2026-02-24 01:45:27'),
(211, 2, 'Collection started for area ID 3 scheduled on 2026-02-27', 0, '2026-02-24 01:47:48'),
(212, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 41).', 0, '2026-02-24 01:47:48'),
(213, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 41).', 0, '2026-02-24 01:47:48'),
(215, 2, 'Collection started for area ID 1 scheduled on 2026-02-28', 0, '2026-02-24 01:47:55'),
(216, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 46).', 0, '2026-02-24 01:47:55'),
(217, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 46).', 0, '2026-02-24 01:47:55'),
(219, 2, 'Collection started for area ID 3 scheduled on 2026-02-27', 0, '2026-02-24 02:16:53'),
(220, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 48).', 0, '2026-02-24 02:16:53'),
(221, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 48).', 0, '2026-02-24 02:16:53'),
(223, 2, 'Collection started for area ID 1 scheduled on 2026-02-28', 0, '2026-02-24 02:17:18'),
(224, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 47).', 0, '2026-02-24 02:17:18'),
(225, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 47).', 0, '2026-02-24 02:17:18'),
(227, 2, 'Collection started for area ID 1 scheduled on 2026-02-28', 0, '2026-02-25 11:21:19'),
(228, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 49).', 0, '2026-02-25 11:21:19'),
(229, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 49).', 0, '2026-02-25 11:21:19'),
(231, 2, 'Collection started for area ID 3 scheduled on 2026-02-26', 0, '2026-02-25 11:21:29'),
(232, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 50).', 0, '2026-02-25 11:21:29'),
(233, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 50).', 0, '2026-02-25 11:21:29'),
(235, 2, 'Collection started for area ID 1 scheduled on 2026-02-27', 0, '2026-02-25 12:44:19'),
(236, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 51).', 0, '2026-02-25 12:44:19'),
(237, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 51).', 0, '2026-02-25 12:44:19'),
(238, 2, 'Collection started for area ID 1 scheduled on 2026-03-18', 0, '2026-03-09 12:42:32'),
(239, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 52).', 0, '2026-03-09 12:42:32'),
(240, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 52).', 0, '2026-03-09 12:42:32'),
(242, 1, 'New role created: test', 0, '2026-03-10 07:44:01'),
(243, 1, 'New area added: Mogadishu - waberi (Bakara)', 0, '2026-03-10 08:04:53'),
(244, 1, 'New area added: Mogadishu - Hodon (Taleh)', 0, '2026-03-10 08:05:04'),
(245, 1, 'New area added: Mogadishu - Hodon (Bakara)', 0, '2026-03-10 08:44:13'),
(246, 1, 'New area added: Mogadishu - Hodon (biyamalow)', 0, '2026-03-10 08:44:27'),
(247, 1, 'New area added: Mogadishu - Hodon (Taleh)', 0, '2026-03-10 08:44:41'),
(248, 1, 'New bin added: HD002 | Area: Hodon | Capacity: 6866kg', 0, '2026-03-10 08:53:21'),
(249, 3, 'New bin added: HD002 | Area: Hodon | Capacity: 6866kg', 0, '2026-03-10 08:53:21'),
(251, 1, 'New bin added: HD003 | Area: Hodon | Capacity: 74566kg', 0, '2026-03-10 08:59:47'),
(252, 3, 'New bin added: HD003 | Area: Hodon | Capacity: 74566kg', 0, '2026-03-10 08:59:47'),
(254, 1, 'New bin added: HD004 | Area: Hodon | Capacity: 5678kg', 0, '2026-03-10 09:32:55'),
(255, 3, 'New bin added: HD004 | Area: Hodon | Capacity: 5678kg', 0, '2026-03-10 09:32:55'),
(257, 1, 'New bin added: test001 | Area: Hodon | Capacity: 8878kg', 0, '2026-03-10 10:02:56'),
(258, 3, 'New bin added: test001 | Area: Hodon | Capacity: 8878kg', 0, '2026-03-10 10:02:56'),
(260, 1, 'New bin added: HD002 | Area: Hodon | Capacity: 5000kg', 0, '2026-03-10 13:53:54'),
(261, 3, 'New bin added: HD002 | Area: Hodon | Capacity: 5000kg', 0, '2026-03-10 13:53:54'),
(263, 1, 'New bin added: HD003 | Area: Hodon | Capacity: 6000kg', 0, '2026-03-10 13:54:21'),
(264, 3, 'New bin added: HD003 | Area: Hodon | Capacity: 6000kg', 0, '2026-03-10 13:54:21'),
(266, 4, 'Welcome shire jaamac geedi! Your account has been created.', 0, '2026-03-10 14:05:21'),
(267, 1, 'New user created: shire jaamac geedi (Role: admin)', 0, '2026-03-10 14:05:21'),
(268, 5, 'Welcome Mahad Mohamed raage! Your account has been created.', 0, '2026-03-10 14:08:08'),
(269, 1, 'New user created: Mahad Mohamed raage (Role: admin)', 0, '2026-03-10 14:08:08'),
(270, 6, 'Welcome test Ali test! Your account has been created.', 0, '2026-03-10 14:39:32'),
(271, 1, 'New user created: test Ali test (Role: admin)', 0, '2026-03-10 14:39:32'),
(272, 1, 'New vehicle added: 009 | Capacity: 7888 kg. Ready for assignment.', 0, '2026-03-11 07:48:37'),
(273, 3, 'New vehicle added: 009 | Capacity: 7888 kg. Ready for assignment.', 0, '2026-03-11 07:48:37'),
(275, 1, 'New bin added: WB003 | Area: waberi | Capacity: 5678kg', 0, '2026-03-12 09:41:23'),
(276, 3, 'New bin added: WB003 | Area: waberi | Capacity: 5678kg', 0, '2026-03-12 09:41:23'),
(278, 1, 'New vehicle added: 0010 | Capacity: 45678 kg. Ready for assignment.', 0, '2026-03-12 09:42:51'),
(279, 3, 'New vehicle added: 0010 | Capacity: 45678 kg. Ready for assignment.', 0, '2026-03-12 09:42:51'),
(281, 2, 'Collection started for area ID 3 scheduled on 2026-03-11', 0, '2026-03-12 09:48:41'),
(282, 1, 'Driver ID 2 started collection for area ID 3 (schedule ID 53).', 0, '2026-03-12 09:48:41'),
(283, 3, 'Driver ID 2 started collection for area ID 3 (schedule ID 53).', 0, '2026-03-12 09:48:41'),
(285, 2, 'Collection started for area ID 1 scheduled on 2026-03-13', 0, '2026-03-12 09:59:20'),
(286, 1, 'Driver ID 2 started collection for area ID 1 (schedule ID 58).', 0, '2026-03-12 09:59:20'),
(287, 3, 'Driver ID 2 started collection for area ID 1 (schedule ID 58).', 0, '2026-03-12 09:59:20'),
(289, 4, 'Collection started for area ID 3 scheduled on 2026-03-31', 0, '2026-03-12 11:36:34'),
(290, 1, 'Driver ID 4 started collection for area ID 3 (schedule ID 57).', 0, '2026-03-12 11:36:34'),
(291, 3, 'Driver ID 4 started collection for area ID 3 (schedule ID 57).', 0, '2026-03-12 11:36:34');

-- --------------------------------------------------------

--
-- Stand-in structure for view `pending_bin_requests`
-- (See below for the actual view)
--
CREATE TABLE `pending_bin_requests` (
`id` int(11)
,`area_id` int(11)
,`bin_id` int(11)
,`full_name` varchar(100)
,`phone` varchar(20)
,`request_type` varchar(50)
,`district` varchar(100)
,`bin_code` varchar(50)
,`status` enum('pending','approved','collected','rejected')
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `pending_house_hold_requests`
-- (See below for the actual view)
--
CREATE TABLE `pending_house_hold_requests` (
`id` int(11)
,`full_name` varchar(100)
,`phone` varchar(20)
,`request_type` varchar(50)
,`area_id` int(11)
,`district` varchar(100)
,`address` varchar(255)
,`status` enum('pending','approved','collected','rejected')
);

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `description`, `created_at`) VALUES
(1, 'admin', 'test 1', '2026-02-06 03:43:03'),
(2, 'driver', 'something else hh', '2026-02-06 03:43:19'),
(3, 'supervisor', 'all access ok', '2026-02-06 03:43:43');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role_id` int(11) NOT NULL,
  `area_id` int(11) DEFAULT NULL,
  `status` varchar(200) DEFAULT 'active',
  `last_login_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `full_name`, `phone`, `email`, `password`, `role_id`, `area_id`, `status`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'Abdikadir Mohamed', '+1290200011', 'mahadyare122122@gmail.com', '0192023a7bbd73250516f069df18b500', 1, 3, 'active', NULL, '2026-02-06 03:49:24', NULL),
(2, 'najka Abdi', '31425364758967', 'abzaict@gmail.com', 'c974f63abee678d0e103167ad9c813a5', 2, 1, 'active', NULL, '2026-02-06 03:49:58', NULL),
(3, 'geedi raage ali', '345678', 'beder@gmail.com', '1425d5d3160aa6bd140605cc75e63ce0', 3, 3, 'active', NULL, '2026-02-06 03:50:43', NULL),
(4, 'shire jaamac geedi', '+1290200011', 'Zaki2002.d@gmail.com', '202cb962ac59075b964b07152d234b70', 2, 1, 'active', NULL, '2026-03-10 14:05:21', NULL),
(5, 'Mahad Mohamed raage', '6161834789', 'dadirgm44@gmail.com', '64e08b1a779fa093cf1ab4af4d4c6892', 2, 1, 'active', NULL, '2026-03-10 14:08:08', NULL),
(6, 'test Ali test', '638597078', 'test@gmail.com', '202cb962ac59075b964b07152d234b70', 2, 1, 'inactive', NULL, '2026-03-10 14:39:32', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `id` int(11) NOT NULL,
  `vehicle_number` varchar(50) NOT NULL,
  `capacity_kg` int(11) NOT NULL,
  `current_load_kg` int(11) DEFAULT 0 CHECK (`current_load_kg` <= `capacity_kg`),
  `status` varchar(200) DEFAULT 'available',
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vehicles`
--

INSERT INTO `vehicles` (`id`, `vehicle_number`, `capacity_kg`, `current_load_kg`, `status`, `updated_at`) VALUES
(1, '001', 5000, 0, 'available', NULL),
(2, '002', 2000, 0, 'on_route', NULL),
(3, '005', 6000, 0, 'on_route', NULL),
(4, '004', 5500, 0, 'inactive', NULL),
(5, '006', 556, 0, 'inactive', NULL),
(6, '007', 7787, 0, 'inactive', NULL),
(7, '008', 800, 0, 'on_route', NULL),
(8, '009', 8000, 0, 'inactive', NULL),
(9, '0010', 45678, 0, 'available', NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_users`
-- (See below for the actual view)
--
CREATE TABLE `vw_users` (
`id` int(11)
,`full_name` varchar(100)
,`email` varchar(100)
,`phone` varchar(20)
,`status` varchar(200)
,`last_login_at` datetime
,`created_at` timestamp
,`role_id` int(11)
,`role_name` varchar(50)
,`area_id` int(11)
,`area_name` varchar(100)
);

-- --------------------------------------------------------

--
-- Table structure for table `waste_request`
--

CREATE TABLE `waste_request` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `request_target` varchar(50) NOT NULL,
  `area_id` int(11) NOT NULL,
  `bin_id` int(11) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','collected','rejected') DEFAULT 'pending',
  `schedule_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `waste_request`
--

INSERT INTO `waste_request` (`id`, `full_name`, `phone`, `request_target`, `area_id`, `bin_id`, `address`, `status`, `schedule_id`, `created_at`) VALUES
(4, 'geedi raage ali', '616029001', 'bin', 1, 5, NULL, 'collected', 3, '2026-02-06 04:08:17'),
(5, 'shire jaamac', '526374856', 'bin', 3, 4, NULL, 'collected', 4, '2026-02-06 04:08:51'),
(6, 'moha ali', '616080877', 'bin', 1, 5, NULL, 'collected', 5, '2026-02-14 13:43:38'),
(7, 'Abza ict', '6575758677', 'bin', 1, 5, NULL, 'collected', 7, '2026-02-16 17:31:55'),
(8, 'eng shire', '61602938457', 'bin', 1, 5, NULL, 'collected', 8, '2026-02-17 03:15:45'),
(9, 'Abza ict', '757567', 'bin', 1, 5, NULL, 'collected', 9, '2026-02-17 03:59:20'),
(10, 'mahad', '576589', 'bin', 3, 4, NULL, 'collected', 10, '2026-02-17 03:59:38'),
(11, 'Abza ict', '61603954', 'bin', 1, 5, NULL, 'collected', 11, '2026-02-17 04:04:33'),
(12, 'uyttouy', '4865768', 'bin', 3, 4, NULL, 'collected', 12, '2026-02-17 04:04:57'),
(13, 'dsgg', '763577', 'bin', 1, 5, NULL, 'collected', 14, '2026-02-17 04:19:43'),
(14, 'uiot', '425364', 'bin', 3, 4, NULL, 'collected', 15, '2026-02-17 04:20:08'),
(15, 'rgrh', '456', 'bin', 1, 5, NULL, 'collected', 16, '2026-02-17 04:31:45'),
(16, 'retry', '679999', 'bin', 3, 4, NULL, 'collected', 17, '2026-02-17 04:32:00'),
(17, 'Abza ict', '55', 'bin', 1, 5, NULL, 'collected', 18, '2026-02-17 04:36:41'),
(18, 'sadfgg', '43578', 'bin', 3, 4, NULL, 'collected', 20, '2026-02-17 04:36:55'),
(19, 'eds', '43556', 'bin', 1, 5, NULL, 'collected', 21, '2026-02-17 04:39:36'),
(20, 'asdgfg', '432546', 'bin', 3, 4, NULL, 'collected', 22, '2026-02-17 04:39:50'),
(21, 'Abza ict', '12345', 'bin', 1, 5, NULL, 'collected', 23, '2026-02-17 04:42:39'),
(22, 'Abza ict', '23456', 'bin', 3, 4, NULL, 'collected', 24, '2026-02-17 04:42:58'),
(23, 'ertyu', '45678', 'bin', 1, 5, NULL, 'collected', 26, '2026-02-22 00:10:09'),
(24, 'dfgh', '5678', 'bin', 3, 4, NULL, 'collected', 27, '2026-02-22 00:10:22'),
(25, 'dfgh', '45678', 'bin', 1, 5, NULL, 'collected', 28, '2026-02-22 00:24:21'),
(26, 'sdfghj', '45678', 'bin', 3, 4, NULL, 'collected', 29, '2026-02-22 00:24:32'),
(27, 'ertyu', '456789', 'bin', 1, 5, NULL, 'collected', 30, '2026-02-22 00:36:45'),
(28, 'erty', '4567', 'bin', 3, 4, NULL, 'collected', 31, '2026-02-22 00:36:58'),
(29, 'rtyu', '34567', 'bin', 1, 5, NULL, 'collected', 32, '2026-02-22 01:23:22'),
(30, 'geedi raage ali', '4567890', 'house_hold', 3, NULL, 'jsfkjgghj', 'collected', 35, '2026-02-23 11:09:07'),
(31, 'shire', '5678', 'bin', 3, 4, NULL, 'collected', 34, '2026-02-23 11:10:24'),
(32, 'shire jaamac', '234567', 'house_hold', 1, NULL, 'ssjhjfjhgkhj', 'collected', 33, '2026-02-23 11:33:19'),
(33, 'beder hotel', '123456', 'house_hold', 3, NULL, 'sjjgfkhgj', 'collected', 36, '2026-02-23 11:33:49'),
(34, 'geedi raage ali', '5678', 'house_hold', 3, NULL, 'jsfkjgghj', 'approved', 42, '2026-02-23 14:00:44'),
(35, 'shire jaamac', '5678', 'house_hold', 1, NULL, 'jsfkjgghj', 'collected', 37, '2026-02-23 14:01:54'),
(36, 'shire', '45678', 'bin', 1, 5, NULL, 'collected', 38, '2026-02-23 14:22:12'),
(37, 'beder hotel', '12345', 'bin', 3, 4, NULL, 'collected', 41, '2026-02-23 20:43:57'),
(38, 'shire jaamac', '23456', 'bin', 1, 5, NULL, 'collected', 39, '2026-02-23 22:58:40'),
(39, 'geedi raage ali', '12345', 'bin', 1, 5, NULL, 'collected', 40, '2026-02-24 01:33:07'),
(40, 'Najka Shire', '1234', 'house_hold', 3, NULL, 'Taleh  ', 'collected', 43, '2026-02-24 01:33:39'),
(41, 'ytre', '12345', 'house_hold', 1, NULL, 'jsfkjgghj', 'collected', 44, '2026-02-24 01:43:49'),
(42, 'geedi raage ali', '45678', 'house_hold', 1, NULL, '444', 'collected', 45, '2026-02-24 01:44:03'),
(43, 'geedi raage ali', '122122', 'bin', 1, 5, NULL, 'collected', 46, '2026-02-24 01:46:51'),
(44, 'geedi raage ali', '12345', 'bin', 3, 4, NULL, 'collected', 48, '2026-02-24 02:12:02'),
(45, 'beder hotel', '2345', 'house_hold', 1, NULL, 'ssjhjfjhgkhj', 'collected', 47, '2026-02-24 02:12:14'),
(46, 'mohamed Farah Gedi', '6153848597', 'bin', 1, 5, NULL, 'collected', 49, '2026-02-25 07:18:54'),
(47, 'shire mohamed  mahad', '616384946', 'house_hold', 3, NULL, 'jsfkjgghj', 'collected', 50, '2026-02-25 07:19:19'),
(49, 'Abdirashid', '4253647586', 'bin', 1, 5, NULL, 'collected', 51, '2026-02-25 07:57:51'),
(52, 'seybiyano', '4567890', 'house_hold', 1, NULL, 'talex', 'approved', 56, '2026-02-25 11:22:56'),
(53, 'geedi raage ali', '42536458', 'bin', 1, 5, NULL, 'collected', 52, '2026-02-25 12:44:46'),
(55, 'Mahad Mohamed raage', '567', 'bin', 3, 10, NULL, 'approved', 54, '2026-03-11 10:16:09'),
(56, 'shire jaamac', '2345', 'house_hold', 3, NULL, 'jsfkjgghj', 'pending', NULL, '2026-03-11 10:30:10'),
(57, 'beder hotel', '2345', 'house_hold', 3, NULL, 'ssjhjfjhgkhj', 'pending', NULL, '2026-03-11 10:30:37'),
(64, 'Abdikadir Mohamed', '34567', 'bin', 1, 5, NULL, 'approved', 55, '2026-03-11 11:03:20'),
(66, 'Mahad Mohamed raage', '5678', 'bin', 3, 4, NULL, 'collected', 53, '2026-03-11 11:07:18'),
(67, 'geedi raage ali', '345678', 'bin', 3, 4, NULL, 'collected', 57, '2026-03-12 09:54:39'),
(68, 'geedi raage ali', '34567', 'bin', 1, 12, NULL, 'collected', 58, '2026-03-12 09:57:24');

-- --------------------------------------------------------

--
-- Table structure for table `waste_requests`
--

CREATE TABLE `waste_requests` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `bin_id` int(11) DEFAULT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `area_id` int(11) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `request_type` enum('household','bulk','hazardous') NOT NULL,
  `estimated_weight_kg` int(11) DEFAULT NULL,
  `preferred_date` date DEFAULT NULL,
  `status` enum('pending','approved','assigned','collected','rejected') DEFAULT 'pending',
  `rejection_reason` varchar(255) DEFAULT NULL,
  `schedule_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure for view `pending_bin_requests`
--
DROP TABLE IF EXISTS `pending_bin_requests`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `pending_bin_requests`  AS SELECT `w`.`id` AS `id`, `w`.`area_id` AS `area_id`, `w`.`bin_id` AS `bin_id`, `w`.`full_name` AS `full_name`, `w`.`phone` AS `phone`, `w`.`request_target` AS `request_type`, `a`.`name` AS `district`, `b`.`bin_code` AS `bin_code`, `w`.`status` AS `status` FROM ((`waste_request` `w` join `areas` `a` on(`w`.`area_id` = `a`.`id`)) join `bins` `b` on(`w`.`bin_id` = `b`.`id`)) WHERE `w`.`request_target` = 'bin' AND `w`.`status` = 'pending' ;

-- --------------------------------------------------------

--
-- Structure for view `pending_house_hold_requests`
--
DROP TABLE IF EXISTS `pending_house_hold_requests`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `pending_house_hold_requests`  AS SELECT `w`.`id` AS `id`, `w`.`full_name` AS `full_name`, `w`.`phone` AS `phone`, `w`.`request_target` AS `request_type`, `w`.`area_id` AS `area_id`, `a`.`name` AS `district`, `w`.`address` AS `address`, `w`.`status` AS `status` FROM (`waste_request` `w` join `areas` `a` on(`w`.`area_id` = `a`.`id`)) WHERE `w`.`request_target` = 'house_hold' AND `w`.`status` = 'pending' ;

-- --------------------------------------------------------

--
-- Structure for view `vw_users`
--
DROP TABLE IF EXISTS `vw_users`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_users`  AS SELECT `u`.`id` AS `id`, `u`.`full_name` AS `full_name`, `u`.`email` AS `email`, `u`.`phone` AS `phone`, `u`.`status` AS `status`, `u`.`last_login_at` AS `last_login_at`, `u`.`created_at` AS `created_at`, `r`.`id` AS `role_id`, `r`.`name` AS `role_name`, `a`.`id` AS `area_id`, `a`.`name` AS `area_name` FROM ((`users` `u` join `roles` `r` on(`u`.`role_id` = `r`.`id`)) left join `areas` `a` on(`u`.`area_id` = `a`.`id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `areas`
--
ALTER TABLE `areas`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bins`
--
ALTER TABLE `bins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `bin_code` (`bin_code`),
  ADD KEY `area_id` (`area_id`);

--
-- Indexes for table `collection_logs`
--
ALTER TABLE `collection_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `schedule_id` (`schedule_id`),
  ADD KEY `bin_id` (`bin_id`),
  ADD KEY `collection_logs_ibfk_3` (`request_id`);

--
-- Indexes for table `collection_schedule`
--
ALTER TABLE `collection_schedule`
  ADD PRIMARY KEY (`id`),
  ADD KEY `area_id` (`area_id`),
  ADD KEY `vehicle_id` (`vehicle_id`),
  ADD KEY `driver_id` (`driver_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `role_id` (`role_id`),
  ADD KEY `area_id` (`area_id`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `vehicle_number` (`vehicle_number`);

--
-- Indexes for table `waste_request`
--
ALTER TABLE `waste_request`
  ADD PRIMARY KEY (`id`),
  ADD KEY `area_id` (`area_id`),
  ADD KEY `bin_id` (`bin_id`),
  ADD KEY `schedule_id` (`schedule_id`);

--
-- Indexes for table `waste_requests`
--
ALTER TABLE `waste_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `area_id` (`area_id`),
  ADD KEY `schedule_id` (`schedule_id`),
  ADD KEY `bin_id` (`bin_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `areas`
--
ALTER TABLE `areas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `bins`
--
ALTER TABLE `bins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `collection_logs`
--
ALTER TABLE `collection_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT for table `collection_schedule`
--
ALTER TABLE `collection_schedule`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=293;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `waste_request`
--
ALTER TABLE `waste_request`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT for table `waste_requests`
--
ALTER TABLE `waste_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bins`
--
ALTER TABLE `bins`
  ADD CONSTRAINT `bins_ibfk_1` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`);

--
-- Constraints for table `collection_logs`
--
ALTER TABLE `collection_logs`
  ADD CONSTRAINT `collection_logs_ibfk_1` FOREIGN KEY (`schedule_id`) REFERENCES `collection_schedule` (`id`),
  ADD CONSTRAINT `collection_logs_ibfk_2` FOREIGN KEY (`bin_id`) REFERENCES `bins` (`id`),
  ADD CONSTRAINT `collection_logs_ibfk_3` FOREIGN KEY (`request_id`) REFERENCES `waste_request` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `collection_schedule`
--
ALTER TABLE `collection_schedule`
  ADD CONSTRAINT `collection_schedule_ibfk_1` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`),
  ADD CONSTRAINT `collection_schedule_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`),
  ADD CONSTRAINT `collection_schedule_ibfk_3` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `collection_schedule_ibfk_4` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`);

--
-- Constraints for table `waste_request`
--
ALTER TABLE `waste_request`
  ADD CONSTRAINT `waste_request_ibfk_1` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`),
  ADD CONSTRAINT `waste_request_ibfk_2` FOREIGN KEY (`bin_id`) REFERENCES `bins` (`id`),
  ADD CONSTRAINT `waste_request_ibfk_3` FOREIGN KEY (`schedule_id`) REFERENCES `collection_schedule` (`id`);

--
-- Constraints for table `waste_requests`
--
ALTER TABLE `waste_requests`
  ADD CONSTRAINT `waste_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `waste_requests_ibfk_2` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`),
  ADD CONSTRAINT `waste_requests_ibfk_3` FOREIGN KEY (`schedule_id`) REFERENCES `collection_schedule` (`id`),
  ADD CONSTRAINT `waste_requests_ibfk_4` FOREIGN KEY (`bin_id`) REFERENCES `bins` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
