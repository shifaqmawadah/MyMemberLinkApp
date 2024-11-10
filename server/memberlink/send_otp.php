<?php
include 'db_connection.php'; // Include your database connection here

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST['email'];

    // Check if the email exists in the database
    $query = "SELECT * FROM users WHERE email = '$email'";
    $result = mysqli_query($conn, $query);
    if (mysqli_num_rows($result) > 0) {
        // Generate a random OTP
        $otp = rand(100000, 999999);

        // Store the OTP in the database for verification later (optional)
        $updateQuery = "UPDATE users SET otp = '$otp' WHERE email = '$email'";
        mysqli_query($conn, $updateQuery);

        // Send OTP to the user's email using PHP mail() or any other email service
        $subject = "Your OTP for Password Reset";
        $message = "Your OTP is: $otp";
        $headers = "From: no-reply@yourdomain.com";

        if (mail($email, $subject, $message, $headers)) {
            echo json_encode(["status" => "success"]);
        } else {
            echo json_encode(["status" => "failed"]);
        }
    } else {
        echo json_encode(["status" => "user_not_found"]);
    }
}
?>
