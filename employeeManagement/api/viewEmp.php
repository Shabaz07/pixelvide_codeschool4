<?php

require_once './utils/db.php'; 
require_once './utils/response.php';

if ($_SERVER["REQUEST_METHOD"] !== "GET") {
    sendErrorMessage("Invalid Method", 405);
}

// Required parameters
if (!isset($_GET['token']) || !isset($_GET['emp_id'])) {
    sendErrorMessage("Token and emp_id are required", 400);
}

$token = $_GET['token'];
$emp_id = $_GET['emp_id'];

// Validate emp_id is numeric
if (!is_numeric($emp_id)) {
    sendErrorMessage("Invalid emp_id", 400);
}

$emp_id = (int)$emp_id;

$pdo = getPDO();

// Validate token
$query = "SELECT * FROM admin WHERE token = :token";
$stmt = $pdo->prepare($query);
$stmt->bindParam(":token", $token, PDO::PARAM_STR);
$stmt->execute();
$admin = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$admin) {
    sendErrorMessage("Invalid token", 401);
}

// Fetch employee details
$query = "
    SELECT 
        e.id,
        e.firstname AS first_name,
        e.lastname AS last_name,
        e.surname,
        e.doj AS date_of_joining,
        e.dob AS date_of_birth,
        g.gender,
        e.phone,
        ws.description AS working_status,
        d.description AS designation,
        l.district AS location,
        e.gross
    FROM employees e
    JOIN gender g ON e.gender_id = g.id
    JOIN working_status ws ON e.working_status_id = ws.id
    JOIN designations d ON e.designation_id = d.id
    JOIN location l ON e.location_id = l.id
    WHERE e.id = :emp_id
";

$stmt = $pdo->prepare($query);
$stmt->bindParam(":emp_id", $emp_id, PDO::PARAM_INT);
$stmt->execute();
$employee = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$employee) {
    sendErrorMessage("Employee not found", 404);
}

sendSuccessMessage("success",$employee);
