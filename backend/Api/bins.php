<?php
header("content-type: application/json");
include '../config/conn.php';
   
function register_bin($conn)
{
    extract($_POST);
    $data = array();
    $query = "CALL sp_insert_bin ('$code', '$area', '$capacity')";
    $result = $conn->query($query);
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row['msg'] == 'Bin code is required') {
            $data = array("status" => false, "data" => "Bin code is required");
        } 
        elseif ($row['msg'] == 'Invalid area') {
            $data = array("status" => false, "data" => "Invalid area");
        }
        elseif ($row['msg'] == 'Invalid bin capacity') {
            $data = array("status" => false, "data" => "Invalid bin capacity");
        }
        elseif ($row['msg'] == 'Bin already exists') {
            $data = array("status" => false, "data" => "Bin already exists");
        }
    
        elseif ($row['msg'] == 'Bin added successfully') {
            $data = array("status" => true, "data" => "Bin added successfully");
        }
    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}

function fill_areas_dropdown($conn){
    $data = array();
    $array_data = array();
   $query ="SELECT id, concat(name, ' - ', zone) area FROM `areas`";
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

function read_Bins($conn)
{
    extract($_POST);
    $data = array();
    $array_data = array();
    $query = "SELECT b.id 'id', b.bin_code 'bin_code', b.capacity_kg 'capacity', concat(a.name, ' - ', a.zone) 'area', b.status 'status' FROM bins b JOIN areas a ON b.area_id = a.id";
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

function get_bins_info($conn){
    extract($_POST);
    $data = array();
    $array_data = array();
   $query ="SELECT * FROM bins where id= '$update_id'";
    $result = $conn->query($query);


    if($result){
        $row = $result->fetch_assoc();
        
        $data = array("status" => true, "data" => $row);


    }else{
        $data = array("status" => false, "data"=> $conn->error);
             
    }

    echo json_encode($data);
}

function update_bins($conn){

    extract($_POST);

    $data = array();

        $query = "UPDATE bins SET bin_code = '$code', area_id = '$area',  capacity_kg = '$capacity'  WHERE id = '$update_id'";
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

function delete_bins($conn){

    extract($_POST);

    $data = array();

    try{

        $query = "DELETE FROM bins WHERE id = '$delete_id'";
        $result = $conn->query($query);

        if($result){

            $data = array(
                "status" => true,
                "data" => "Bin deleted successfully"
            );

        }

    }catch(mysqli_sql_exception $e){

        if($e->getCode() == 1451){

            $data = array(
                "status" => false,
                "data" => "Delete not allowed: this Bin is linked to other records."
            );

        }else{

            $data = array(
                "status" => false,
                "data" => "Something went wrong while deleting the area."
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
