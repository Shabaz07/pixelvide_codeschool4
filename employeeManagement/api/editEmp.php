<?php

require_once './utils/db.php';
require_once './utils/response.php';

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    sendErrorMessage("Invalid request method", 405);
}

// Collect and sanitize POST input
$data = $_POST;

// Required fields
$requiredFields = ['token', 'emp_id', 'first_name', 'last_name', 'surname', 'doj', 'dob', 'gender', 'phone', 'working_status', 'designation', 'location', 'gross'];
foreach ($requiredFields as $field) {
    if (empty($data[$field])) {
        sendErrorMessage("Missing or empty field: $field", 400);
    }
}

$token = $data['token'];
$emp_id = (int) $data['emp_id'];

// DB connection
$pdo = getPDO();

// Validate token
$stmt = $pdo->prepare("SELECT id FROM admin WHERE token = :token");
$stmt->bindParam(":token", $token);
$stmt->execute();

if ($stmt->rowCount() === 0) {
    sendErrorMessage("Invalid token", 401);
}

// Resolve foreign keys
function getId($pdo, $table, $column, $value) {
    $stmt = $pdo->prepare("SELECT id FROM $table WHERE $column = :value");
    $stmt->bindParam(":value", $value);
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$result) {
        sendErrorMessage("Invalid value for $table: $value", 400);
    }

    return $result['id'];
}

$gender_id = getId($pdo, 'gender', 'gender', $data['gender']);
$working_status_id = getId($pdo, 'working_status', 'description', $data['working_status']);
$designation_id = getId($pdo, 'designations', 'description', $data['designation']);
$location_id = getId($pdo, 'location', 'district', $data['location']);

// Update employee
$updateQuery = "
    UPDATE employees SET 
        firstname = :first_name,
        lastname = :last_name,
        surname = :surname,
        doj = :doj,
        dob = :dob,
        gender_id = :gender_id,
        phone = :phone,
        working_status_id = :working_status_id,
        designation_id = :designation_id,
        location_id = :location_id,
        gross = :gross
    WHERE id = :emp_id
";

$stmt = $pdo->prepare($updateQuery);
$stmt->execute([
    ':first_name' => $data['first_name'],
    ':last_name' => $data['last_name'],
    ':surname' => $data['surname'],
    ':doj' => $data['doj'],
    ':dob' => $data['dob'],
    ':gender_id' => $gender_id,
    ':phone' => $data['phone'],
    ':working_status_id' => $working_status_id,
    ':designation_id' => $designation_id,
    ':location_id' => $location_id,
    ':gross' => $data['gross'],
    ':emp_id' => $emp_id
]);

sendSuccessMessage("Employee updated successfully");

