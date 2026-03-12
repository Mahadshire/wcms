<?php
header("content-type: application/json");
include '../config/conn.php';
// $action = $_POST['action'];

        
function register_user($conn)
{
    extract($_POST);
    $data = array();
    $query = "CALL sp_insert_user ('$role_id', '$fullname', '$email', '$phone',  MD5('$password'), '$area_id')";
    $result = $conn->query($query);
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row['msg'] == 'Full name is required') {
            $data = array("status" => false, "data" => "Full name is required");
        } 
        elseif ($row['msg'] == 'Email is required') {
            $data = array("status" => false, "data" => "Email is required");
        }
        elseif ($row['msg'] == 'Password is required') {
            $data = array("status" => false, "data" => "Password is required");
        }
        elseif ($row['msg'] == 'Invalid role') {
            $data = array("status" => false, "data" => "Invalid role");
        }
        elseif ($row['msg'] == 'Invalid area') {
            $data = array("status" => false, "data" => "Invalid area");
        }
        elseif ($row['msg'] == 'Email already exists') {
            $data = array("status" => false, "data" => "Email already exists");
        }
        elseif ($row['msg'] == 'User created successfully, notifications sent') {
            $data = array("status" => true, "data" => "User created successfully");
        }
    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}

function fill_roles($conn){
    $data = array();
    $array_data = array();
   $query ="SELECT id, name FROM `roles`";
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
function fill_area($conn){
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

function read_users($conn)
{
    extract($_POST);
    $data = array();
    $array_data = array();
    $query = "SELECT id, full_name, email, phone,role_name 'role', status FROM vw_users where status = 'active'";
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


function get_user_info($conn){
    extract($_POST);
    $data = array();
    $array_data = array();
   $query ="SELECT * FROM users where id= '$update_id'";
    $result = $conn->query($query);


    if($result){
        $row = $result->fetch_assoc();
        
        $data = array("status" => true, "data" => $row);


    }else{
        $data = array("status" => false, "data"=> $conn->error);
             
    }

    echo json_encode($data);
}

function update_users($conn){

    extract($_POST);

    $data = array();

        $query = "UPDATE users SET full_name = '$fullname', email = '$email',  password= MD5('$password'), role_id = '$role_id', area_id = '$area_id'  WHERE id = '$update_id'";
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

// function delete_user($conn){

//     extract($_POST);

//     $data = array();

//     try{

//         $query = "UPDATE users set status = 'inactive' WHERE id =  '$delete_id'";
//         $result = $conn->query($query);

//         if($result){

//             $data = array(
//                 "status" => true,
//                 "data" => "User deleted successfully"
//             );

//         }

//     }catch(mysqli_sql_exception $e){

//         if($e->getCode() == 1451){

//             $data = array(
//                 "status" => false,
//                 "data" => "Delete not allowed: this User is linked to other records."
//             );

//         }else{

//             $data = array(
//                 "status" => false,
//                 "data" => "Something went wrong while deleting the User."
//             );

//         }
//     }

//     echo json_encode($data);
// }



function delete_user($conn){

    session_start();
    extract($_POST);

    $data = array();

    try{

        // Get user role
        $checkQuery = "SELECT role_name FROM vw_users WHERE id = '$delete_id'";
        $result = $conn->query($checkQuery);
        $row = $result->fetch_assoc();

        // ❌ Reject if admin
        if($row['role_name'] == 'admin'){
            $data = array(
                "status" => false,
                "data" => "Admin users cannot be deleted."
            );
            echo json_encode($data);
            return;
        }

        // ❌ Reject if deleting the currently logged-in user
        if(isset($_SESSION['id']) && $_SESSION['id'] == $delete_id){
            $data = array(
                "status" => false,
                "data" => "You cannot delete the user who is currently logged in."
            );
            echo json_encode($data);
            return;
        }

        // Soft delete
        $query = "UPDATE users SET status = 'inactive' WHERE id = '$delete_id'";
        $result = $conn->query($query);

        if($result){
            $data = array(
                "status" => true,
                "data" => "User deleted successfully"
            );
        }

    }catch(mysqli_sql_exception $e){

        if($e->getCode() == 1451){
            $data = array(
                "status" => false,
                "data" => "Delete not allowed: this User is linked to other records."
            );
        }else{
            $data = array(
                "status" => false,
                "data" => "Something went wrong while deleting the User."
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
