<?php

header("Access-Control-Allow-Origin: *");  // Allow all origins
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");  // Allow common HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization");  // Allow these headers

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    // Handle preflight requests
    header('HTTP/1.1 200 OK');
    exit();}

if (!isset($_POST)) {
    $response = array('status' => 'failed', 'message' => 'No POST data received.');
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$email = $_POST['email'];
$password = sha1($_POST['password']); // Secure hashing

// Check for duplicate email
$checkEmailQuery = "SELECT * FROM `tbl_admins` WHERE `admin_email` = '$email'";
$result = $conn->query($checkEmailQuery);

if ($result->num_rows > 0) {
    $response = array('status' => 'failed', 'message' => 'Email already exists.');
    sendJsonResponse($response);
    die;
}

// Insert into the database
$sqlInsert = "INSERT INTO `tbl_admins`(`admin_email`, `admin_pass`) VALUES ('$email','$password')";
if ($conn->query($sqlInsert) === TRUE) {
    $response = array('status' => 'success', 'message' => 'Registration successful.');
} else {
    $response = array('status' => 'failed', 'message' => 'Database error: ' . $conn->error);
}

sendJsonResponse($response);

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>