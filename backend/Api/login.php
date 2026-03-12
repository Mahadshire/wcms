<?php
session_start();
header("Content-Type: application/json");
include '../config/conn.php';

function Login($conn)
{
    extract($_POST);
    $data = array();

    $query = "CALL sp_login('$email','$password')";
    $result = $conn->query($query);

    if ($result) {

        $row = $result->fetch_assoc();

        if (!$row) {
            $data = array("status" => false, "data" => "No response from system");
        }
        // ❌ Wrong login
        elseif ($row['msg'] === 'Deny') {
            $data = array("status" => false, "data" => "Username or password is incorrect");
        }
        // 🔒 Locked account
        elseif ($row['msg'] === 'Locked') {
            $data = array("status" => false, "data" => "Account is locked");
        }
        // ✅ SUCCESS (admin / driver / supervisor)
        else {
            foreach ($row as $key => $value) {
                $_SESSION[$key] = $value;
            }

            $data = array(
                "status" => true,
                "role"   => $row['msg'], // admin | driver | supervisor
                "data"   => "success"
            );
        }

        // clear extra result sets (IMPORTANT for stored procedures)
        while ($conn->more_results() && $conn->next_result()) {}

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
