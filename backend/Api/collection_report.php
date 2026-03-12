<?php

header("Content-type: application/json");

include '../config/conn.php';

function Bin_Collection_Report($conn)
{
    extract($_POST);

    $data = array();
    $message = array();
    // Read all Bin Collection Data
    if($type == 0){
        $query = "call sp_bin_collection_report('$type', null, null)";
    }else{
        $query = "call sp_bin_collection_report('$type', '$from', '$to')";
    }
   


    // excute the query

    $result = $conn->query($query);

    // success or error

    if ($result) {

        while ($row = $result->fetch_assoc()) {

            $data[] = $row;
        }

        $message = array("status" => true, "data" => $data);
    } else {

        $message = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($message);
}



if (isset($_POST['action'])) {
    $action = $_POST['action'];
    $action($conn);
} else {
    echo Json_encode(array("status" => false, "data" => "acction is required"));
}