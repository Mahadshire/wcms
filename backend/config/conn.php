<?php

    $conn = new mysqli("localhost", "root", "", "wcms");

    if($conn->connect_error){
        echo $conn->error;
    }
?>