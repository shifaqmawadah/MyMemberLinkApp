<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include_once("dbconnect.php");

// Retrieve POST parameters
$product_id = isset($_POST['product_id']) ? intval($_POST['product_id']) : 0;
$quantity = isset($_POST['quantity']) ? intval($_POST['quantity']) : 1;
$admin_id = isset($_POST['admin_id']) ? $_POST['admin_id'] : '';
$admin_email = isset($_POST['admin_email']) ? $_POST['admin_email'] : '';
 
if ($product_id > 0 && $quantity > 0 && !empty($admin_id) && !empty($admin_email)) {
    // Insert or update cart with admin details
    $sql = "INSERT INTO tbl_cart (product_id, admin_id, admin_email, quantity) 
            VALUES ('$product_id', '$admin_id', '$admin_email', '$quantity')
            ON DUPLICATE KEY UPDATE quantity = quantity + $quantity";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(['status' => 'success', 'message' => 'Product added to cart']);
    } else {
        echo json_encode(['status' => 'fail', 'message' => 'Failed to add product to cart: ' . $conn->error]);
    }
} else {
    echo json_encode(['status' => 'fail', 'message' => 'Invalid product ID, quantity, or admin details']);
}
?>