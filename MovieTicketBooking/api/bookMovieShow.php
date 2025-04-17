<?php

require_once("./utils/db.php");
require_once("./utils/response.php");

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    sendErrorMessage("Invalid Method", 404);
}

if (!isset($_POST["token"])) {
    sendErrorMessage("Token is required", 400);
}
if (!isset($_POST["movieId"]) || !isset($_POST["categoryId"]) || !isset($_POST["theaterId"]) || !isset($_POST["showTime"])) {
    sendErrorMessage("movieId, categoryId, theaterId, and showTime are required", 400);
}

$token = $_POST['token'];
$categoryId = $_POST['categoryId'];
$movieId = $_POST['movieId'];
$theaterId = $_POST['theaterId'];
$showTime = $_POST['showTime'];
$screens = $_POST['screens'];

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

//add show
$query = "INSERT INTO movieShows(movie_id, theater_id, movie_category_id, movie_title, show_time_id,movie_screens, theater_name, status) VALUES
          (:movieId, :theaterId, :categoryId,
          (SELECT title FROM movies WHERE id = :movieId), :showTime, :screens,
          (SELECT name FROM theaters WHERE id = :theaterId), 'Available')";

$stmt = $pdo->prepare($query);
$stmt->bindParam(":movieId", $movieId, PDO::PARAM_INT);
$stmt->bindParam(":theaterId", $theaterId, PDO::PARAM_INT);
$stmt->bindParam(":screens", $screens, PDO::PARAM_INT);
$stmt->bindParam(":categoryId", $categoryId, PDO::PARAM_INT);
$stmt->bindParam(":showTime", $showTime, PDO::PARAM_STR);
$stmt->execute();

$rowCount = $stmt->rowCount();

ob_end_clean();
header('Content-Type: application/json');
echo json_encode([
    "status" => "success",
    "message" => "$rowCount show(s) movie added successfully"
]);
exit;