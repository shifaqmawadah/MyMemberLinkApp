<?php

header("Access-Control-Allow-Origin: *");  // Allow all origins
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");  // Allow common HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization");  // Allow these headers

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    // Handle preflight requests
    header('HTTP/1.1 200 OK');
    exit();
}

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

$email = $_POST['email'];
$password = sha1($_POST['password']);

$sqllogin = "SELECT `admin_email`, `admin_pass` FROM `tbl_admins` WHERE `admin_email` = '$email' AND `admin_pass` = '$password'";
$result = $conn->query($sqllogin);

if ($result) { // Check if query execution is successful
    if ($result->num_rows > 0) {
        $response = array('status' => 'success', 'data' => null);
    } else {
        $response = array('status' => 'failed', 'message' => 'Invalid email or password');
    }
} else {
    $response = array('status' => 'failed', 'message' => 'Database query failed');
}

sendJsonResponse($response); // Send a single response at the end
	
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>