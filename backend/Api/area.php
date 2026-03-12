<?php
header("content-type: application/json");
include '../config/conn.php';
// $action = $_POST['action'];

        
function register_area($conn)
{
    extract($_POST);
    $data = array();
    $query = "CALL sp_insert_area ('$name', '$city', '$zone')";
    $result = $conn->query($query);
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row['msg'] == 'City is required') {
            $data = array("status" => false, "data" => "City is required");
        } 
        elseif ($row['msg'] == 'Area name is required') {
            $data = array("status" => false, "data" => "Area name is required");
        }
        elseif ($row['msg'] == 'Zone is required') {
            $data = array("status" => false, "data" => "Zone is required");
        }
        elseif ($row['msg'] == 'This area already exists in the specified zone') {
            $data = array("status" => false, "data" => "This area already exists in the specified zone");
        }
        elseif ($row['msg'] == 'Area created successfully') {
            $data = array("status" => true, "data" => "Area created successfully");
        }
    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}

function read_area($conn)
{
    extract($_POST);
    $data = array();
    $array_data = array();
    $query = "SELECT * FROM areas";
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

function get_Area_info($conn){
    extract($_POST);
    $data = array();
    $array_data = array();
   $query ="SELECT * FROM areas where id= '$update_id'";
    $result = $conn->query($query);


    if($result){
        $row = $result->fetch_assoc();
        
        $data = array("status" => true, "data" => $row);


    }else{
        $data = array("status" => false, "data"=> $conn->error);
             
    }

    echo json_encode($data);
}

function update_Area($conn){

    extract($_POST);

    $data = array();

        $query = "UPDATE areas SET name = '$name', city = '$city', zone = '$zone'  WHERE id = '$update_id'";
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

// function delete_area($conn){

//     extract($_POST);

//     $data = array();

//     // Check if Area is used by any bins
//     $checkQuery = "SELECT id FROM bins WHERE area_id = '$delete_id'";
//     $checkResult = $conn->query($checkQuery);

//     if($checkResult->num_rows > 0){

//         $data = array(
//             "status" => false,
//             "data" => "This role cannot be deleted because it is assigned to users"
//         );

//     }else{

//         $query = "DELETE FROM areas WHERE id = '$delete_id'";
//         $result = $conn->query($query);

//         if($result){

//             $data = array(
//                 "status" => true,
//                 "data" => "Area deleted successfully"
//             );

//         }else{

//             $data = array(
//                 "status" => false,
//                 "data" => $conn->error
//             );
//         }
//     }

//     echo json_encode($data);
// }

function delete_area($conn){

    extract($_POST);

    $data = array();

    try{

        $query = "DELETE FROM areas WHERE id = '$delete_id'";
        $result = $conn->query($query);

        if($result){

            $data = array(
                "status" => true,
                "data" => "Area deleted successfully"
            );

        }

    }catch(mysqli_sql_exception $e){

        if($e->getCode() == 1451){

            $data = array(
                "status" => false,
                "data" => "Delete not allowed: this area is linked to other records."
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
