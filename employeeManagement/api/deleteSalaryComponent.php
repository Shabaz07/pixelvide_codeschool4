<?php
ob_start();
require_once './utils/db.php';
require_once './utils/response.php';

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(404);
    sendErrorMessage("Invalid Method", 404);
}

if (!isset($_POST["token"]) || !isset($_POST["detail_id"])) {
    http_response_code(400);
    sendErrorMessage("Token and detail_id are required", 400);
}

$token = $_POST['token'];
$detail_id = $_POST['detail_id'];
$pdo = getPDO();

$stmt = $pdo->prepare("SELECT * FROM admin WHERE token = ?");
$stmt->execute([$token]);
if (!$stmt->fetch()) {
    http_response_code(401);
    sendErrorMessage("Token invalid", 401);
}

$query = "SELECT salary_id, sc.type 
    FROM salary_details sd 
    JOIN salary_components sc ON sd.salary_component_id = sc.id 
    WHERE sd.id = ?";
$stmt = $pdo->prepare($query);
$stmt->execute([$detail_id]);
$component = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$component) {
    http_response_code(404);
    sendErrorMessage("Component not found", 404);
}

$salary_id = $component["salary_id"];

$deleteStmt = $pdo->prepare("DELETE FROM salary_details WHERE id = ?");
$deleteStmt->execute([$detail_id]);

$earningsStmt = $pdo->prepare("
    SELECT COALESCE(SUM(sd.amount), 0) AS total
    FROM salary_details sd
    JOIN salary_components sc ON sd.salary_component_id = sc.id
    WHERE sd.salary_id = ? AND sc.type = 1
");
$earningsStmt->execute([$salary_id]);
$earningsTotal = $earningsStmt->fetchColumn();

$deductionsStmt = $pdo->prepare("
    SELECT COALESCE(SUM(sd.amount), 0) AS total
    FROM salary_details sd
    JOIN salary_components sc ON sd.salary_component_id = sc.id
    WHERE sd.salary_id = ? AND sc.type = 2
");
$deductionsStmt->execute([$salary_id]);
$deductionsTotal = $deductionsStmt->fetchColumn();

$updateStmt = $pdo->prepare("UPDATE salaries SET gross = ?, deduction = ? WHERE id = ?");
$updateStmt->execute([$earningsTotal, $deductionsTotal, $salary_id]);

ob_end_clean();
http_response_code(200);
header('Content-Type: application/json');
echo json_encode(["status" => "success", "message" => "Component deleted", "salary_id" => $salary_id]);
exit;
?>