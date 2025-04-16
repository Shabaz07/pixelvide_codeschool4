<?php
ob_start();

require_once("./utils/db.php");
require_once("./utils/response.php");
require_once("./utils/token.php");

if ($_SERVER["REQUEST_METHOD"] != 'POST') {
    sendErrorMessage("Not found", 404);
}

if (!isset($_POST["username"])) {
    sendErrorMessage("Missing username", 400);
}

if (!isset($_POST["password"])) {
    sendErrorMessage("Password is missing", 400);
}

$username = $_POST["username"];
$password = $_POST["password"];

$pdo = getPDO();
$query = "SELECT * FROM admin WHERE username = :username AND password = :password";
$statement = $pdo->prepare($query);
$statement->bindParam("username", $username, PDO::PARAM_STR);
$statement->bindParam("password", $password, PDO::PARAM_STR);
$statement->execute();

$data = $statement->fetch(PDO::FETCH_ASSOC);
if (!$data) {
    sendErrorMessage("Username and password are invalid", 400);
}

$token = getRandomToken();
$data["token"] = $token;

$query = "UPDATE admin SET token = :token WHERE id = :id";
$statement = $pdo->prepare($query);
$statement->bindParam("token", $token, PDO::PARAM_STR);
$statement->bindParam("id", $data["id"], PDO::PARAM_INT);
$statement->execute();

unset($data["password"]);

ob_end_clean();
header('Content-Type: application/json');
echo json_encode([
    "success" => true,
    "message" => "Logged Successfully",
    "data" => $data
]);
exit;