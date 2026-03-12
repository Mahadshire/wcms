<?php

header("Content-type: application/json");

include '../config/conn.php';

function collection_Schedule_Report($conn)
{
    extract($_POST);

    $data = array();
    $message = array();
  
    $query = "call sp_collection_schedule_by_status('$type')";


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