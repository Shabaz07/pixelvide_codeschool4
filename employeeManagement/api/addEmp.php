<?php
// api/addEmp.php
require_once './utils/db.php'; 
require_once './utils/response.php';

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    sendErrorMessage("Invalid Method", 405);
}

// Required POST parameters (relaxed validation)
$requiredFields = ['emp_id', 'first_name', 'last_name', 'designation', 'token'];
$optionalFields = ['surname', 'doj', 'dob', 'gender', 'phone', 'working_status', 'location', 'gross'];

foreach ($requiredFields as $field) {
    if (!isset($_POST[$field]) || empty($_POST[$field])) {
        sendErrorMessage("Missing or empty required field: $field", 400);
    }
}

// Sanitize and assign values
$emp_id = (int)$_POST['emp_id'];
$first_name = $_POST['first_name'];
$last_name = $_POST['last_name'];
$surname = $_POST['surname'] ?? null;
$doj = $_POST['doj'] ?? null;
$dob = $_POST['dob'] ?? null;
$gender = $_POST['gender'];
$phone = $_POST['phone'] ?? null;
$working_status = $_POST['working_status'];
$designation = $_POST['designation'];
$location = $_POST['location'] ?? null;
$gross = $_POST['gross'] ?? null;
$token = $_POST['token'];

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

// Convert foreign keys (with null handling)
function getForeignKeyId($pdo, $table, $column, $value) {
    $stmt = $pdo->prepare("SELECT id FROM $table WHERE $column = :value LIMIT 1");
    $stmt->execute(['value' => $value]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        return $result['id'];
    } else {
        $insert = $pdo->prepare("INSERT INTO $table ($column) VALUES (:value)");
        $insert->execute(['value' => $value]);
        return $pdo->lastInsertId();
    }
}

$gender_id = getForeignKeyId($pdo, 'gender', 'gender', $gender); // Fixed syntax error
$working_status_id = getForeignKeyId($pdo, 'working_status', 'description', $working_status);
$designation_id = getForeignKeyId($pdo, 'designations', 'description', $designation);
$location_id = getForeignKeyId($pdo, 'location', 'district', $location);

// Insert employee
$query = "
    INSERT INTO employees (id, firstname, lastname, surname, doj, dob, gender_id, phone, working_status_id, designation_id, location_id, gross)
    VALUES (:id, :firstname, :lastname, :surname, :doj, :dob, :gender_id, :phone, :working_status_id, :designation_id, :location_id, :gross)
";

$stmt = $pdo->prepare($query);

try {
    $stmt->execute([
        ':id' => $emp_id,
        ':firstname' => $first_name,
        ':lastname' => $last_name,
        ':surname' => $surname,
        ':doj' => $doj,
        ':dob' => $dob,
        ':gender_id' => $gender_id,
        ':phone' => $phone,
        ':working_status_id' => $working_status_id,
        ':designation_id' => $designation_id,
        ':location_id' => $location_id,
        ':gross' => $gross
    ]);

    sendSuccessMessage("Employee added successfully");
} catch (PDOException $e) {
    sendErrorMessage("Database error: " . $e->getMessage(), 500);
}
?>