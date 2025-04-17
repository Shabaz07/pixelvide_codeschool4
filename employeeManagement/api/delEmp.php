<?php

require_once './utils/db.php'; 
require_once './utils/response.php';

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    sendErrorMessage("Invalid Method", 405);
}

// Required parameters
if (!isset($_POST['token']) || !isset($_POST['emp_id'])) {
    sendErrorMessage("Token and emp_id are required", 400);
}

$token = $_POST['token'];
$emp_id = $_POST['emp_id'];

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

// Check if employee exists
$query = "SELECT * FROM employees WHERE id = :emp_id";
$stmt = $pdo->prepare($query);
$stmt->bindParam(":emp_id", $emp_id, PDO::PARAM_INT);
$stmt->execute();
$employee = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$employee) {
    sendErrorMessage("Employee not found", 404);
}

// Begin transaction to ensure atomicity
try {
    $pdo->beginTransaction();

    // Step 1: Delete related records from salary_details (via salaries)
    $query = "DELETE FROM salary_details WHERE salary_id IN (SELECT id FROM salaries WHERE employee_id = :emp_id)";
    $stmt = $pdo->prepare($query);
    $stmt->bindParam(":emp_id", $emp_id, PDO::PARAM_INT);
    $stmt->execute();

    // Step 2: Delete related records from salaries
    $query = "DELETE FROM salaries WHERE employee_id = :emp_id";
    $stmt = $pdo->prepare($query);
    $stmt->bindParam(":emp_id", $emp_id, PDO::PARAM_INT);
    $stmt->execute();

    // Step 3: Delete the employee
    $query = "DELETE FROM employees WHERE id = :emp_id";
    $stmt = $pdo->prepare($query);
    $stmt->bindParam(":emp_id", $emp_id, PDO::PARAM_INT);
    $stmt->execute();

    // Commit the transaction
    $pdo->commit();
    sendSuccessMessage("Employee and related records deleted successfully");
} catch (PDOException $e) {
    // Roll back the transaction on error
    $pdo->rollBack();
    sendErrorMessage("An error occurred: " . $e->getMessage(), 500);
}
