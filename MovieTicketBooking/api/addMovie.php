<?php

require_once("./utils/db.php");
require_once("./utils/response.php");

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    sendErrorMessage("Invalid Method", 404);
}

if (!isset($_POST["token"])) {
    sendErrorMessage("Token is required", 400);
}
if (!isset($_POST["movieTitle"]) || !isset($_POST["categoryId"]) || !isset($_POST["movieGenre"])
    || !isset($_POST["addActors"] )|| !isset($_POST["addReleaseDate"] ) || !isset($_POST["addMovieDuration"] ) 
    || !isset($_POST["moviePoster"] ) || !isset($_POST["addMovieDescription"] )) {

    sendErrorMessage("movieId, categoryId, theaterId, and showTime are required", 400);

}

$token = $_POST['token'];
$categoryId = $_POST['categoryId'];
$movieTitle = $_POST['movieTitle'];
$movieGenre = $_POST['movieGenre'];
$addActors = $_POST['addActors'];
$addReleaseDate = $_POST['addReleaseDate'];
$addMovieDuration = $_POST['addMovieDuration'];
$addMovieDescription = $_POST['addMovieDescription'];
$moviePoster = $_POST['moviePoster'];

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

//add movie
$query = "INSERT INTO movies (poster, title, released_date, category_id, genre, actors, description, duration, rating) VALUES
            (:moviePoster,:movieTitle,:addReleaseDate,:categoryId,:movieGenre,:addActors,:addMovieDescription,:addMovieDuration,4)";

$stmt = $pdo->prepare($query);
$stmt->bindParam(":moviePoster", $moviePoster, PDO::PARAM_INT);
$stmt->bindParam(":movieTitle", $movieTitle, PDO::PARAM_INT);
$stmt->bindParam(":addReleaseDate", $addReleaseDate, PDO::PARAM_INT);
$stmt->bindParam(":categoryId", $categoryId, PDO::PARAM_INT);
$stmt->bindParam(":movieGenre", $movieGenre, PDO::PARAM_STR);
$stmt->bindParam(":addActors", $addActors, PDO::PARAM_STR);
$stmt->bindParam(":addMovieDescription", $addMovieDescription, PDO::PARAM_STR);
$stmt->bindParam(":addMovieDuration", $addMovieDuration, PDO::PARAM_STR);


$stmt->execute();

$rowCount = $stmt->rowCount();

ob_end_clean();
header('Content-Type: application/json');
echo json_encode([
    "status" => "success",
    "message" => "$rowCount show(s) added successfully"
]);
exit;