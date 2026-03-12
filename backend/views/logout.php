<?php
session_start();
unset($_SESSION['email']);
unset($_SESSION['full_name']);
unset($_SESSION['role']);
// unset($_SESSION['date']);
    header('Location:login.php');
?>