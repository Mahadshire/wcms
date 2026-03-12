<?php
header("content-type: application/json");
include '../config/conn.php';
// $action = $_POST['action'];

        
function register_roles($conn)
{
    extract($_POST);
    $data = array();
    $query = "CALL sp_insert_role('$role', '$description')";
    $result = $conn->query($query);
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row['msg'] == 'Role name is required') {
            $data = array("status" => false, "data" => "Role name is required");
        } 
        elseif ($row['msg'] == 'Role already exists') {
            $data = array("status" => false, "data" => "Role already exists");
        }
        elseif ($row['msg'] == 'Role created successfully') {
            $data = array("status" => true, "data" => "Role created successfully");
        }
    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}

function read_roles($conn)
{
    extract($_POST);
    $data = array();
    $array_data = array();
    $query = "SELECT * FROM roles";
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


function get_role_info($conn){
    extract($_POST);
    $data = array();
    $array_data = array();
   $query ="SELECT *FROM roles where id= '$update_id'";
    $result = $conn->query($query);


    if($result){
        $row = $result->fetch_assoc();
        
        $data = array("status" => true, "data" => $row);


    }else{
        $data = array("status" => false, "data"=> $conn->error);
             
    }

    echo json_encode($data);
}


// function update_roles($conn){
//     extract($_POST);

//     $data = array();

//     $query = "UPDATE roles set name = '$role', description = '$desc' WHERE id = '$update_id'";
     

//     $result = $conn->query($query);


//     if($result){

//             $data = array("status" => true, "data" => "successfully updated");


//     }else{
//         $data = array("status" => false, "data"=> $conn->error);
             
//     }

//     echo json_encode($data);
// }

function update_roles($conn){

    extract($_POST);

    $data = array();

    // Check if role name already exists in another record
    $checkQuery = "SELECT id FROM roles WHERE name = '$role' AND id != '$update_id'";
    $checkResult = $conn->query($checkQuery);

    if($checkResult->num_rows > 0){

        $data = array(
            "status" => false,
            "data" => "Role duplicate is not allowed"
        );

    }else{

        $query = "UPDATE roles SET name = '$role', description = '$desc' WHERE id = '$update_id'";
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
    }

    echo json_encode($data);
}

// function Delete_roles($conn){
//     extract($_POST);
//     $data = array();
//     $array_data = array();
//    $query ="DELETE FROM roles where id= '$delete_id'";
//     $result = $conn->query($query);


//     if($result){
//         $data = array("status" => true, "data" => "successfully Deleted😎");
//     }else{
//         $data = array("status" => false, "data"=> $conn->error);
             
//     }

//     echo json_encode($data);
// }

function delete_role($conn){

    extract($_POST);

    $data = array();

    // Check if role is used by any user
    $checkQuery = "SELECT id FROM users WHERE role_id = '$delete_id'";
    $checkResult = $conn->query($checkQuery);

    if($checkResult->num_rows > 0){

        $data = array(
            "status" => false,
            "data" => "This role cannot be deleted because it is assigned to users"
        );

    }else{

        $query = "DELETE FROM roles WHERE id = '$delete_id'";
        $result = $conn->query($query);

        if($result){

            $data = array(
                "status" => true,
                "data" => "Role deleted successfully"
            );

        }else{

            $data = array(
                "status" => false,
                "data" => $conn->error
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
