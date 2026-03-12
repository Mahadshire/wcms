<?php
header("content-type: application/json");
include '../config/conn.php';
// $action = $_POST['action'];

        
function register_vehicles($conn)
{
    extract($_POST);
    $data = array();
    $query = "CALL sp_add_vehicle('$vehicle_number', '$capacity')";
    $result = $conn->query($query);
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row['msg'] == 'Vehicle number is required') {
            $data = array("status" => false, "data" => "Vehicle number is required");
        } 
        elseif ($row['msg'] == 'Vehicle capacity must be greater than 0') {
            $data = array("status" => false, "data" => "Vehicle capacity must be greater than 0");
        }
        elseif ($row['msg'] == 'Vehicle already exists') {
            $data = array("status" => false, "data" => "Vehicle already exists");
        }
    
        elseif ($row['msg'] == 'Vehicle added successfully') {
            $data = array("status" => true, "data" => "Vehicle added successfully");
        }
    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}

function read_vehicles($conn)
{
    extract($_POST);
    $data = array();
    $array_data = array();
    $query = "SELECT id, vehicle_number, capacity_kg 'capacity', status FROM `vehicles` where status != 'inactive'";
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


function get_vehicle_info($conn){
    extract($_POST);
    $data = array();
    $array_data = array();
   $query ="SELECT * FROM vehicles where id= '$update_id'";
    $result = $conn->query($query);


    if($result){
        $row = $result->fetch_assoc();
        
        $data = array("status" => true, "data" => $row);


    }else{
        $data = array("status" => false, "data"=> $conn->error);
             
    }

    echo json_encode($data);
}

function update_vehicles($conn){

    extract($_POST);

    $data = array();

        $query = "UPDATE vehicles SET vehicle_number = '$vehicle', capacity_kg = '$capacity' WHERE id = '$update_id'";
        $result = $conn->query($query);

        if($result){

            $data = array(
                "status" => true,
                "data" => "Successfully updated"
            );

        }else{

            $data = array(
                "status" => false,
                "data" => $conn->error
            );
        }

    echo json_encode($data);
}


function delete_vehicles($conn){
    extract($_POST);

    $data = array();

    try{

        // Get user role
        $checkQuery = "SELECT status FROM vehicles WHERE id = '$delete_id'";
        $result = $conn->query($checkQuery);
        $row = $result->fetch_assoc();

        // ❌ Reject if admin
        if($row['status'] != 'available'){
            $data = array(
                "status" => false,
                "data" => "You Can't Delete This vehicle ❌"
            );
            echo json_encode($data);
            return;
        }
        // Soft delete
        $query = "UPDATE vehicles SET status = 'inactive' WHERE id = '$delete_id'";
        $result = $conn->query($query);

        if($result){
            $data = array(
                "status" => true,
                "data" => "vehicle deleted successfully"
            );
        }

    }catch(mysqli_sql_exception $e){

        if($e->getCode() == 1451){
            $data = array(
                "status" => false,
                "data" => "Delete not allowed: this vehicles is linked to other records."
            );
        }else{
            $data = array(
                "status" => false,
                "data" => "Something went wrong while deleting the vehicle."
            );
        }
    }

    echo json_encode($data);
}




if (isset($_POST['action'])) {
    $action = $_POST['action'];
    $action($conn);
} else {
    echo json_encode(array("status" => false, "data" => "Action Required....."));
}
