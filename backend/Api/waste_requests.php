<?php
header("content-type: application/json");
include '../config/conn.php';
// $action = $_POST['action'];


function approve_bin_collection($conn)
{
    $user_id = 1;

    extract($_POST);
    $data = array();
    $query = "CALL sp_approve_bin_request_lst('$requestId', '$vehicles', '$drivers', '$date', '$user_id')";
    $result = $conn->query($query);
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row['msg'] == 'Request ID is required') {
            $data = array("status" => false, "data" => "Request is required");
        } 
        if ($row['msg'] == 'Vehicle is required') {
            $data = array("status" => false, "data" => "Vehicle is required");
        } 
        if ($row['msg'] == 'Driver is required') {
            $data = array("status" => false, "data" => "Driver is required");
        } 
        if ($row['msg'] == 'Collection date is required') {
            $data = array("status" => false, "data" => "Collection date is required");
        } 
        if ($row['msg'] == 'Request not found or not pending') {
            $data = array("status" => false, "data" => "Request not found or not pending");
        } 
        if ($row['msg'] == 'Bin does not belong to the selected area') {
            $data = array("status" => false, "data" => "Bin does not belong to the selected area");
        } 
        if ($row['msg'] == 'Vehicle is not available') {
            $data = array("status" => false, "data" => "Vehicle is not available");
        } 
        if ($row['msg'] == 'User is not an active driver') {
            $data = array("status" => false, "data" => "User is not an active driver");
        } 
        if ($row['msg'] == 'Only admin or supervisor can approve requests') {
            $data = array("status" => false, "data" => "Only admin or supervisor can approve requests");
        } 
        if ($row['msg'] == 'Collection date cannot be in the past') {
            $data = array("status" => false, "data" => "Collection date cannot be in the past");
        } 
        if ($row['msg'] == 'Driver is already assigned to another schedule on this date') {
            $data = array("status" => false, "data" => "Driver is already assigned to another schedule on this date");
        } 
        if ($row['msg'] == 'This area already has an active schedule on this date') {
            $data = array("status" => false, "data" => "This area already has an active schedule on this date");
        } 
        
    
        elseif ($row['msg'] == 'Bin request approved and schedule created successfully') {
            $data = array("status" => true, "data" => "Bin request approved and schedule created successfully");
        }
    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}

function reject_bin_collection_request($conn){
    extract($_POST);
    $data = array();
    $array_data = array();
   $query ="DELETE FROM waste_request WHERE id = '$rejectId'";
    $result = $conn->query($query);


    if($result){
   
        
        $data = array("status" => true, "data" => "You successfully Rejected This Request");


    }else{
        $data = array("status" => false, "data"=> $conn->error);
             
    }

    echo json_encode($data);
}

function read_pending_bin_requests($conn)
{
    extract($_POST);
    $data = array();
    $array_data = array();
    $query = "SELECT * FROM `pending_bin_requests` WHERE 1";
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

function fill_Vehicles_drpdown($conn){
    $data = array();
    $array_data = array();
   $query ="SELECT id, vehicle_number FROM `vehicles` WHERE status != 'inactive'";
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

function fill_drivers_drpdown($conn){
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


if (isset($_POST['action'])) {
    $action = $_POST['action'];
    $action($conn);
} else {
    echo json_encode(array("status" => false, "data" => "Action Required....."));
}
