<?php
ob_start();

require_once './utils/db.php'; 
require_once './utils/response.php';

if ($_SERVER["REQUEST_METHOD"] !== "GET") {
    sendErrorMessage("Invalid Method", 404);
}

if (!isset($_GET["token"])) {
   sendErrorMessage("Token is required", 400);
}

$token = $_GET['token'];
$pdo = getPDO();

// Verify token
$query = "SELECT * FROM admin WHERE token = :token";
$stmt = $pdo->prepare($query);
$stmt->bindParam(":token", $token, PDO::PARAM_STR);
$stmt->execute();
$admin = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$admin) {
   sendErrorMessage("Token invalid", 401);
}

// Fetch all Bookings List
$query = "SELECT c.username AS coustmer_name,
            mc.description AS category,
            m.title AS theater_title,
            t.name AS movie_name,
            st.start_time,
            bs.bookingStatus 
            FROM bookShow bs   
            JOIN movie_categories mc on mc.id = bs.movie_category_id
            JOIN movies m ON m.id = bs.movie_id
            JOIN theaters t ON t.id = bs.theater_id
            JOIN showTimes st ON st.id = bs.show_time_id
            JOIN customers c ON t.id = bs.customer_id";

$stmt = $pdo->prepare($query);
$stmt->execute();

$tbookingsList = $stmt->fetchAll(PDO::FETCH_ASSOC);

ob_end_clean();
header('Content-Type: application/json');
echo json_encode([
    "status" => "success",
    "data" => $tbookingsList
]);
exit;