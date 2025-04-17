<?php
ob_start(); // Prevent stray output

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

// Fetch all employees
$query = "SELECT 
        CONCAT(e.firstname, ' ', e.lastname, ' ', e.surname) AS name,
        e.doj, e.dob, g.gender, e.phone, 
        ws.description AS working_status, 
        d.description AS designation, 
        l.district AS location,
        e.id
    FROM employees e
    JOIN gender g ON e.gender_id = g.id
    JOIN working_status ws ON e.working_status_id = ws.id
    JOIN designations d ON e.designation_id = d.id
    JOIN location l ON e.location_id = l.id";
$stmt = $pdo->prepare($query);
$stmt->execute();

$employees = $stmt->fetchAll(PDO::FETCH_ASSOC);

ob_end_clean();
header('Content-Type: application/json');
echo json_encode([
    "status" => "success",
    "data" => $employees
]);
exit;