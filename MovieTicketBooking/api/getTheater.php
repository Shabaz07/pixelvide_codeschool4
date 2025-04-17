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

// Fetch all Theater List
$query = "SELECT t.id AS id,
            t.name AS theater_name,
            t.location AS location,
            t.screens AS screens,
            st.start_time AS start_time,
            t.status 
            FROM theaters t 
            JOIN showTimes st ON t.showTime = st.id";

$stmt = $pdo->prepare($query);
$stmt->execute();

$theaterList = $stmt->fetchAll(PDO::FETCH_ASSOC);

ob_end_clean();
sendSuccessMessage("success",$theaterList);