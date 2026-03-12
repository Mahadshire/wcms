<?php
header("content-type: application/json");
include '../config/conn.php';
// $action = $_POST['action'];

        
// function register_waste_request($conn)
// {
//     extract($_POST);
//     $data = array();
//     $query = "CALL sp_create_waste_request ('$fullname', '$number', '$wasteType', '$areaId', '$binId', '$address')";
//     $result = $conn->query($query);
//     if ($result) {
//         $row = $result->fetch_assoc();
//         if ($row['msg'] == 'Request type is required') {
//             $data = array("status" => false, "data" => "Request type is required");
//         } 
//         elseif ($row['msg'] == 'Area is required') {
//             $data = array("status" => false, "data" => "Area is required");
//         }
//         elseif ($row['msg'] == 'Full name or phone is required') {
//             $data = array("status" => false, "data" => "Full name or phone is required");
//         }
//         elseif ($row['msg'] == 'Invalid request type') {
//             $data = array("status" => false, "data" => "Invalid request type");
//         }
//         elseif ($row['msg'] == 'Selected area does not exist') {
//             $data = array("status" => false, "data" => "Selected area does not exist");
//         }
//         elseif ($row['msg'] == 'Bin is required for bin request') {
//             $data = array("status" => false, "data" => "Bin is required for bin request");
//         }
//         elseif ($row['msg'] == 'Bin does not belong to selected area') {
//             $data = array("status" => false, "data" => "Bin does not belong to selected area");
//         }
//         elseif ($row['msg'] == 'This bin already has an active request') {
//             $data = array("status" => false, "data" => "This bin already has an active request");
//         }
//         elseif ($row['msg'] == 'Address is required for house hold request') {
//             $data = array("status" => false, "data" => "Address is required for house hold request");
//         }
    
//         elseif ($row['msg'] == 'Waste request submitted successfully') {
//             $data = array("status" => true, "data" => "Waste request submitted successfully");
//         }
//     } else {
//         $data = array("status" => false, "data" => $conn->error);
//     }

//     echo json_encode($data);
// }


function register_waste_request($conn)
{
    extract($_POST);
    $data = array();

    // Call the procedure
    $query = "CALL sp_create_waste_requestUpdated ('$fullname', '$number', '$wasteType', '$areaId', '$binId', '$address')";
    $result = $conn->query($query);

    if ($result) {
        $row = $result->fetch_assoc();

        if ($row['msg'] === 'Waste request submitted successfully') {
            $data = array("status" => true, "data" => $row['msg']);
        } else {
            $data = array("status" => false, "data" => $row['msg']);
        }

    } else {
        $data = array("status" => false, "data" => $conn->error);
    }

    echo json_encode($data);
}



function fill_area_request($conn){
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

function fill_bins_dropdown($conn){
    $areaName = $_POST['areaName'];
    $data = array();
    $array_data = array();
   $query ="SELECT id, bin_code
   FROM bins
   WHERE area_id IN (
       SELECT id FROM areas WHERE name = '$areaName'
   );";
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

// function read_Bins($conn)
// {
//     extract($_POST);
//     $data = array();
//     $array_data = array();
//     $query = "SELECT b.id 'id', b.bin_code 'bin_code', b.capacity_kg 'capacity', a.name 'area', b.last_collected_at 'collected', b.status 'status' FROM bins b JOIN areas a ON b.area_id = a.id";
//     $result = $conn->query($query);


//     if ($result) {
//         while ($row = $result->fetch_assoc()) {
//             $array_data[] = $row;
//         }
//         $data = array("status" => true, "data" => $array_data);
//     } else {
//         $data = array("status" => false, "data" => $conn->error);
//     }

//     echo json_encode($data);
// }




if (isset($_POST['action'])) {
    $action = $_POST['action'];
    $action($conn);
} else {
    echo json_encode(array("status" => false, "data" => "Action Required....."));
}
