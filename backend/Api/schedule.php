<?php
header("content-type: application/json");
include '../config/conn.php';
// $action = $_POST['action'];

        
function register_schedules($conn)
{
    $user_id = 1;

    extract($_POST);
    $data = array();
    $query = "CALL sp_create_collection_schedule('$schedule_area', '$vehicle', '$driver', '$schedule_date', '$user_id')";
    $result = $conn->query($query);
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row['msg'] == 'Area is required') {
            $data = array("status" => false, "data" => "Area is required");
        } 
        elseif ($row['msg'] == 'Vehicle is required') {
            $data = array("status" => false, "data" => "Vehicle is required");
        }
        elseif ($row['msg'] == 'Driver is required') {
            $data = array("status" => false, "data" => "Driver is required");
        }
        elseif ($row['msg'] == 'Collection date is required') {
            $data = array("status" => false, "data" => "Collection date is required");
        }
        elseif ($row['msg'] == 'Area does not exist') {
            $data = array("status" => false, "data" => "Area does not exist");
        }
        elseif ($row['msg'] == 'Vehicle does not exist') {
            $data = array("status" => false, "data" => "Vehicle does not exist");
        }
        elseif ($row['msg'] == 'Driver does not exist') {
            $data = array("status" => false, "data" => "Driver does not exist");
        }
        elseif ($row['msg'] == 'Vehicle is not available') {
            $data = array("status" => false, "data" => "Vehicle is not available");
        }
        elseif ($row['msg'] == 'Collection date cannot be in the past') {
            $data = array("status" => false, "data" => "Collection date cannot be in the past");
        }
        elseif ($row['msg'] == 'Collection already scheduled for this area on this date') {
            $data = array("status" => false, "data" => "Collection already scheduled for this area on this date");
        }
    
        elseif ($row['msg'] == 'Collection schedule created successfully') {
            $data = array("status" => true, "data" => "Collection schedule created successfully");
        }
    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}


function fill_schedule_area($conn){
    $data = array();
    $array_data = array();
   $query ="SELECT MIN(id) AS id, name
   FROM areas
   GROUP BY name;";
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

function fill_Vehicles($conn){
    $data = array();
    $array_data = array();
   $query ="SELECT id, vehicle_number FROM `vehicles`  where status != 'inactive'";
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

function fill_driver($conn){
    $data = array();
    $array_data = array();
   $query ="SELECT u.id 'id', u.full_name 'driver' FROM users u JOIN roles r ON u.role_id = r.id WHERE r.name = 'driver' and STATUS = 'active'";
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

function read_schedules($conn)
{
    extract($_POST);
    $data = array();
    $array_data = array();
    $query = "SELECT cs.id 'id', cs.collection_date, a.name 'district', v.vehicle_number 'vehicle', u.full_name 'driver', cs.status FROM  collection_schedule cs 
JOIN areas a ON cs.area_id = a.id
JOIN users u ON cs.driver_id = u.id
JOIN vehicles v on cs.vehicle_id = v.id";
    $result = $conn->query($query);


    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $array_data[] = $row;
        }
        $data = array("status" => true, "data" => $array_data);
    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}




if (isset($_POST['action'])) {
    $action = $_POST['action'];
    $action($conn);
} else {
    echo json_encode(array("status" => false, "data" => "Action Required....."));
}
