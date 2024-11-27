<?php

header("Access-Control-Allow-Origin: *");  // Allow all origins
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");  // Allow common HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization");  // Allow these headers

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    // Handle preflight requests
    header('HTTP/1.1 200 OK');
    exit();
}

include_once("dbconnect.php");

$results_per_page = 10;
$pageno = isset($_GET['pageno']) ? (int)$_GET['pageno'] : 1;
$page_first_result = ($pageno - 1) * $results_per_page;

// Get search and filter parameters from the GET request
$search = isset($_GET['search']) ? $_GET['search'] : '';
$filter = isset($_GET['filter']) ? $_GET['filter'] : 'All';

// Build SQL query based on filter and search
$sql = "SELECT * FROM `tbl_news` WHERE `news_title` LIKE '%$search%'";

if ($filter == "Last 7 days") {
    $sql .= " AND `news_date` >= NOW() - INTERVAL 7 DAY";
} elseif ($filter == "This Month") {
    $sql .= " AND `news_date` >= NOW() - INTERVAL 1 MONTH";
}

$sql .= " ORDER BY `news_date` DESC LIMIT $page_first_result, $results_per_page";
$result = $conn->query($sql);
$number_of_result = $result->num_rows;
$number_of_page = ceil($number_of_result / $results_per_page);

if ($result->num_rows > 0) {
    $newsarray['news'] = array();
    while ($row = $result->fetch_assoc()) {
        $news = array();
        $news['news_id'] = $row['news_id'];
        $news['news_title'] = $row['news_title'];
        $news['news_details'] = $row['news_details'];
        $news['news_date'] = $row['news_date'];
        array_push($newsarray['news'], $news);
    }
    $response = array('status' => 'success', 'data' => $newsarray, 'numofpage' => $number_of_page, 'numberofresult' => $number_of_result);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null, 'numofpage' => $number_of_page, 'numberofresult' => $number_of_result);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>