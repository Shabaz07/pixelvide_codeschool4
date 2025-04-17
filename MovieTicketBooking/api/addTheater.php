<?php

require_once("./utils/db.php");
require_once("./utils/response.php");

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    sendErrorMessage("Invalid Method", 404);
}

if (!isset($_POST["token"])) {
    sendErrorMessage("Token is required", 400);
}
if (!isset($_POST["theaterName"]) || !isset($_POST["theaterAdd"]) 
    || !isset($_POST["addScreens"]) || !isset($_POST["addShowTimes"] )) {

    sendErrorMessage("All Fields are required", 400);

}

$token = $_POST['token'];
$theaterAdd = $_POST['theaterAdd'];
$theaterName = $_POST['theaterName'];
$addScreens = $_POST['addScreens'];
$addShowTimes = $_POST['addShowTimes'];

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
$query = "INSERT INTO theaters (name, location, screens, showTime) VALUES
            (:theaterName,:theaterAdd,:addScreens,:addShowTimes)";

$stmt = $pdo->prepare($query);
$stmt->bindParam(":theaterName", $theaterName, PDO::PARAM_INT);
$stmt->bindParam(":theaterAdd", $theaterAdd, PDO::PARAM_INT);
$stmt->bindParam(":addScreens", $addScreens, PDO::PARAM_STR);
$stmt->bindParam(":addShowTimes", $addShowTimes, PDO::PARAM_STR);


$stmt->execute();

$rowCount = $stmt->rowCount();

ob_end_clean();
header('Content-Type: application/json');
echo json_encode([
    "status" => "success",
    "message" => "$rowCount show(s) added successfully"
]);
exit;