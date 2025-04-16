<?php

require_once("./utils/db.php");
require_once("./utils/response.php");

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    sendErrorMessage("Invalid Method", 404);
}

if (!isset($_GET["token"])) {
   sendErrorMessage("Token is required", 400);
}
if (!isset($_POST["movieId"]) || ($_POST["categoryId"]) ) {
    sendErrorMessage("movieId is required", 400);
}
$token = $_POST['token'];
$categoryId = $_POST['categoryId'];
$movieId = $_POST['movieId'];
$theaterId = $_POST['theaterId'];
$showTime = $_POST['showTime'];
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

//book show
$query = "INSERT INTO bookShow(movie_category_id,movie_id,theater_id,show_time_id,bookingStatus)
            VALUES (:categoryId,:movieId,:theaterId,:showTime,'Booked')";
$stmt = $pdo->prepare($query);
$stmt->execute();

$bookShow = $stmt->fetchAll(PDO::FETCH_ASSOC);

ob_end_clean();
header('Content-Type: application/json');
echo json_encode([
    "status" => "success",
    "data" => $bookShow
]);
exit;
