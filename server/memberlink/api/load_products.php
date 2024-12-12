<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// If the request method is OPTIONS, respond with a 200 OK (used for CORS preflight)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header('HTTP/1.1 200 OK');
    exit();
}

// Include database connection file
include_once("dbconnect.php");

// Get the page number from the query string, defaulting to 1 if not present
$page = isset($_GET['pageno']) ? intval($_GET['pageno']) : 1;

// Set the number of products per page
$limit = 10;

// Calculate the offset for the SQL query based on the page number
$offset = ($page - 1) * $limit;

// Query to get the total number of products
$sql = "SELECT COUNT(*) AS total FROM tbl_products";
$result = $conn->query($sql);
$total = $result->fetch_assoc()['total'];

// Calculate the number of pages required based on the total number of products
$numofpage = ceil($total / $limit);

// Query to get the products for the current page
$sql = "SELECT * FROM tbl_products LIMIT $limit OFFSET $offset";
$result = $conn->query($sql);

// Initialize an array to hold the products
$products = [];

// Base URL for Google Drive images
$imageBaseUrl = "https://drive.google.com/uc?export=view&id=";

// Fetch each product from the database and append the image URL
while ($row = $result->fetch_assoc()) {
    // Assume product_image contains the Google Drive file ID (not the full URL)
    $row['product_image'] = $imageBaseUrl . $row['product_image'];  // Create the full image URL
    $products[] = $row;
}

// Return the response in JSON format
echo json_encode([
    'status' => 'success',
    'data' => ['products' => $products],
    'numofpage' => $numofpage
]);

?>