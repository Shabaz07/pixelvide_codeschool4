<?php
ob_start();
require_once './utils/db.php';
require_once './utils/response.php';

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(404);
    sendErrorMessage("Invalid Method", 404);
}

if (!isset($_POST["token"]) || !isset($_POST["detailId"]) || !isset($_POST["amount"])) {
    http_response_code(400);
    sendErrorMessage("Token, detailId, and amount are required", 400);
}

$token = $_POST['token'];
$detailId = $_POST['detailId'];
$amount = $_POST['amount'];

if ($amount < 0) {
    http_response_code(400);
    sendErrorMessage("Amount cannot be negative", 400);
}

$pdo = getPDO();

$stmt = $pdo->prepare("SELECT * FROM admin WHERE token = ?");
$stmt->execute([$token]);
if (!$stmt->fetch()) {
    http_response_code(401);
    sendErrorMessage("Token invalid", 401);
}

$updateStmt = $pdo->prepare("UPDATE salary_details SET amount = ? WHERE id = ?");
$updateStmt->execute([$amount, $detailId]);

$salaryStmt = $pdo->prepare("SELECT salary_id FROM salary_details WHERE id = ?");
$salaryStmt->execute([$detailId]);
$salaryId = $salaryStmt->fetchColumn();

$earningsStmt = $pdo->prepare("
    SELECT COALESCE(SUM(sd.amount), 0) AS total
    FROM salary_details sd
    JOIN salary_components sc ON sd.salary_component_id = sc.id
    WHERE sd.salary_id = ? AND sc.type = 1
");
$earningsStmt->execute([$salaryId]);
$earningsTotal = $earningsStmt->fetchColumn();

$deductionsStmt = $pdo->prepare("
    SELECT COALESCE(SUM(sd.amount), 0) AS total
    FROM salary_details sd
    JOIN salary_components sc ON sd.salary_component_id = sc.id
    WHERE sd.salary_id = ? AND sc.type = 2
");
$deductionsStmt->execute([$salaryId]);
$deductionsTotal = $deductionsStmt->fetchColumn();

$updateSalaryStmt = $pdo->prepare("UPDATE salaries SET gross = ?, deduction = ? WHERE id = ?");
$updateSalaryStmt->execute([$earningsTotal, $deductionsTotal, $salaryId]);

ob_end_clean();
http_response_code(200);
header('Content-Type: application/json');
echo json_encode(["status" => "success", "message" => "Component updated", "salary_id" => $salaryId]);
exit;
?>