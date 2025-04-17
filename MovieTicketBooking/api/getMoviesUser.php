<?php
ob_start();

require_once './utils/db.php'; 
require_once './utils/response.php';

header('Content-Type: application/json');

if ($_SERVER["REQUEST_METHOD"] !== "GET") {
    sendErrorMessage("Invalid Method", 404);
}

if (!isset($_GET["token"])) {
   sendErrorMessage("Token is required", 400);
}
if (!isset($_GET["categoryId"])) {
    sendErrorMessage("category Id is required", 400);
}
$token = $_GET['token'];
$categoryId = $_GET['categoryId'];
$pdo = getPDO();

// Verify token
$query = "SELECT * FROM customers WHERE token = :token";
$stmt = $pdo->prepare($query);
$stmt->bindParam(":token", $token, PDO::PARAM_STR);
$stmt->execute();
$customers = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$customers) {
   sendErrorMessage("Token invalid", 401);
}

// Fetch all Movie List
$query = "SELECT poster,title,rating FROM movies";
if ($categoryId){
    $query .= "WHERE category_id = :categoryId";
}
$stmt = $pdo->prepare($query);
$stmt->execute(["categoryId"=>$categoryId]);

$movieList = $stmt->fetchAll(PDO::FETCH_ASSOC);

ob_end_clean();

echo json_encode([
    "status" => "success",
    "data" => $movieList
]);
exit;