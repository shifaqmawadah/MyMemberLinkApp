<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
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

// Updated query to fetch admin_id along with admin_email and admin_pass
$sqllogin = "SELECT `admin_id`, `admin_email`, `admin_pass` FROM `tbl_admins` 
             WHERE `admin_email` = '$email' AND `admin_pass` = '$password'";

$result = $conn->query($sqllogin);

if ($result) { // Check if query execution is successful
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc(); // Fetch admin details
        $response = array(
            'status' => 'success',
            'data' => array(
                'admin_id' => $row['admin_id'],  // Return admin_id
                'admin_email' => $row['admin_email']
            )
        );
        
        // Optional: Store admin_id in session for subsequent requests
        session_start();
        $_SESSION['admin_id'] = $row['admin_id']; 
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