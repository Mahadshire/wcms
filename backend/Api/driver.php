<?php
header("content-type: application/json");
include '../config/conn.php';
// $action = $_POST['action'];
session_start();
if(!isset($_SESSION['id'])){
    echo json_encode(["status"=>false,"data"=>"Not logged in"]);
    exit();
}


function fill_Schedules_driver($conn){
    $data = array();
    $array_data = array();
    $user_id = $_SESSION['id'];
   $query ="SELECT 
    cs.id AS schedule_id, cs.status,
    CONCAT(a.name, ' district - ', cs.collection_date) AS schedule_name
        FROM collection_schedule cs
        JOIN areas a ON cs.area_id = a.id
        WHERE cs.driver_id = '$user_id'
        AND cs.status IN ('scheduled', 'in_progress')
        AND EXISTS (
        SELECT 1
        FROM waste_request w
        WHERE w.schedule_id = cs.id
        AND w.request_target = 'bin'
        )
        ORDER BY cs.collection_date ASC";
    $result = $conn->query($query);


    if($result){
        while($row = $result->fetch_assoc()){
            $array_data[] = $row;
        }
        $data = array("status" => true, "data" => $array_data);


    }else{
        $data = array("status" => false, "data"=> $conn->error);
             
    }

    echo json_encode($data);
}

function fill_House_holds_Schedules_driver($conn){
    $data = array();
    $array_data = array();
    $user_id = $_SESSION['id'];
   $query ="SELECT 
    cs.id AS schedule_id, cs.status,
    CONCAT(a.name, ' district - ', cs.collection_date) AS schedule_name
        FROM collection_schedule cs
        JOIN areas a ON cs.area_id = a.id
        WHERE cs.driver_id = '$user_id'
        AND cs.status IN ('scheduled', 'in_progress')
        AND EXISTS (
        SELECT 1
        FROM waste_request w
        WHERE w.schedule_id = cs.id
        AND w.request_target = 'house_hold'
        )
        ORDER BY cs.collection_date ASC;";
    $result = $conn->query($query);


    if($result){
        while($row = $result->fetch_assoc()){
            $array_data[] = $row;
        }
        $data = array("status" => true, "data" => $array_data);


    }else{
        $data = array("status" => false, "data"=> $conn->error);
             
    }

    echo json_encode($data);
}


function fill_full_bins_to_collect($conn){
    $data = array();
    $array_data = array();
    $schedule_id = $_POST['schedule_id'];
   $query ="SELECT w.id 'request_id', a.name 'district', b.id 'bin_id',  b.bin_code 'Bin', b.status  FROM waste_request w 
    JOIN areas a ON w.area_id = a.id
    JOIN bins b ON w.bin_id = b.id
    JOIN collection_schedule cs ON w.schedule_id = cs.id
    WHERE b.status = 'full' and w.status = 'approved' and schedule_id  = $schedule_id";
    $result = $conn->query($query);


    if($result){
        while($row = $result->fetch_assoc()){
            $array_data[] = $row;
        }
        $data = array("status" => true, "data" => $array_data);


    }else{
        $data = array("status" => false, "data"=> $conn->error);
             
    }

    echo json_encode($data);
}
function fill_all_house_hold_to_collect($conn){
    $data = array();
    $array_data = array();
    $schedule_id = $_POST['scheduleId'];
   $query ="SELECT w.id 'request_id', a.name 'district', w.address, w.status  FROM waste_request w 
    JOIN areas a ON w.area_id = a.id
    JOIN collection_schedule cs ON w.schedule_id = cs.id
    WHERE cs.status IN ('scheduled', 'in_progress') and w.status = 'approved' and schedule_id  = '$schedule_id' and w.request_target = 'house_hold' ";
    $result = $conn->query($query);


    if($result){
        while($row = $result->fetch_assoc()){
            $array_data[] = $row;
        }
        $data = array("status" => true, "data" => $array_data);


    }else{
        $data = array("status" => false, "data"=> $conn->error);
             
    }

    echo json_encode($data);
}

function get_schedule_status($conn){
    $schedule_id = $_POST['schedule_id'];

    $query = "SELECT status FROM collection_schedule WHERE id = $schedule_id";
    $result = $conn->query($query);

    if($row = $result->fetch_assoc()){
        echo json_encode([
            "status" => true,
            "schedule_status" => $row['status']
        ]);
    } else {
        echo json_encode(["status" => false]);
    }
}

function start_collection_schedule($conn)
{
    $user_id = $_SESSION['id'];

    extract($_POST);
    $data = array();
    $schedule_id = $_POST['schedule_id'];
    $query = "CALL sp_start_collection_schedule('$schedule_id', '$user_id')";
    $result = $conn->query($query);
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row['msg'] == 'Schedule not found') {
            $data = array("status" => false, "data" => "Schedule not found");
        } 
        elseif ($row['msg'] == 'This schedule is not assigned to you') {
            $data = array("status" => false, "data" => "This schedule is not assigned to you");
        }
        elseif ($row['msg'] == 'Schedule already started or completed') {
            $data = array("status" => false, "data" => "Schedule already started or completed");
        }
        elseif ($row['msg'] == 'Collection started successfully') {
            $data = array("status" => true, "data" => "Collection started successfully");
        }
       
    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}

function sp_collect_bins($conn)
{
    $user_id = $_SESSION['id'];

    extract($_POST);
    $data = array();
    $query = "CALL sp_collect_bin('$scheduleId', '$user_id', '$requestId', '$binId')";
    $result = $conn->query($query);
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row['msg'] == 'Schedule not active or invalid driver') {
            $data = array("status" => false, "data" => "Schedule not active or invalid driver");
        } 
        elseif ($row['msg'] == 'Invalid or already collected request') {
            $data = array("status" => false, "data" => "Invalid or already collected request");
        }
        elseif ($row['msg'] == 'Bin not ready for collection') {
            $data = array("status" => false, "data" => "Bin not ready for collection");
        }
        elseif ($row['msg'] == 'Collection completed successfully') {
            $data = array("status" => true, "data" => "Collection completed successfully");
        }
       
    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}

function collect_household_waste($conn)
{
    $user_id = $_SESSION['id'];

    extract($_POST);
    $data = array();
    $query = "CALL 	sp_collect_household_waste('$scheduleId', '$user_id', '$requestId')";
    $result = $conn->query($query);
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row['msg'] == 'Schedule not active or invalid driver') {
            $data = array("status" => false, "data" => "Schedule not active or invalid driver");
        } 
        elseif ($row['msg'] == 'Invalid or already collected household request') {
            $data = array("status" => false, "data" => "Invalid or already collected household request");
        }
        elseif ($row['msg'] == 'Household collection completed successfully') {
            $data = array("status" => true, "data" => "Household collection completed successfully");
        }
       
    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}


function complete_schedule($conn)
{
    $driver_id = $_SESSION['id'];
    $schedule_id = $_POST['schedule_id'];

    $query = "CALL sp_complete_schedule('$schedule_id', '$driver_id')";
    $result = $conn->query($query);

    if ($result) {
        $row = $result->fetch_assoc();
        echo json_encode([
            "status" => $row['msg'] === 'Schedule completed successfully',
            "msg" => $row['msg']
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "msg" => $conn->error
        ]);
    }
}

function complete_household_schedule($conn)
{
    $driver_id = $_SESSION['id'];
    $schedule_id = $_POST['schedule_id'];

    $query = "CALL sp_complete_household_schedule('$schedule_id', '$driver_id')";
    $result = $conn->query($query);

    if ($result) {
        $row = $result->fetch_assoc();
        echo json_encode([
            "status" => $row['msg'] === 'Household schedule completed successfully',
            "msg" => $row['msg']
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "msg" => $conn->error
        ]);
    }
}




if (isset($_POST['action'])) {
    $action = $_POST['action'];
    $action($conn);
} else {
    echo json_encode(array("status" => false, "data" => "Action Required....."));
}
