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
$title = addslashes($_POST['title']);
$details =addslashes( $_POST['details']);

$sqlinsertnews="INSERT INTO `tbl_news`(`news_title`, `news_details`) VALUES ('$title','$details')";

if ($conn->query($sqlinsertnews) === TRUE) {
	$response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
}else{
	$response = array('status' => 'failed', 'data' => null);
	sendJsonResponse($response);
}
	
	

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>