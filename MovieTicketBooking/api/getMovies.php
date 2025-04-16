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
if (!isset($_GET["movieId"])) {
    sendErrorMessage("Movie Id is required", 400);
}
$token = $_GET['token'];
$movieId = $_GET['movieId'];
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

// Fetch all Movie List
$query = "SELECT m.id AS id,
            m.title AS title,
            m.released_date AS release_date,
            mc.description AS category,
            m.genre AS gener,
            m.actors AS actors,
            m.status 
            FROM movies m 
            JOIN movie_categories mc on m.category_id = mc.id 
            WHERE mc.id = :movieId ";

$stmt = $pdo->prepare($query);
$stmt->execute(["movieId"=>$movieId]);

$movieList = $stmt->fetchAll(PDO::FETCH_ASSOC);

ob_end_clean();

echo json_encode([
    "status" => "success",
    "data" => $movieList
]);
exit;