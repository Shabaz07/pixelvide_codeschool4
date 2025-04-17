<?php
ob_start();
require_once './utils/db.php';
require_once './utils/response.php';

$token = $_GET['token'] ?? null;
$salaryId = $_GET['salaryId'] ?? null;

if (!$token || !$salaryId) {
    http_response_code(400);
    sendErrorMessage("Token and salary ID are required", 400);
}

$pdo = getPDO();
$stmt = $pdo->prepare("SELECT * FROM admin WHERE token = ?");
$stmt->execute([$token]);
if (!$stmt->fetch()) {
    http_response_code(401);
    sendErrorMessage("Unauthorized", 401);
}

$stmt = $pdo->prepare("
    SELECT 
        s.id,
        s.employee_id,
        s.month,
        s.year,
        s.paid_on,
        s.gross,
        s.deduction,
        s.net
    FROM salaries s
    WHERE s.id = ?
");
$stmt->execute([$salaryId]);
$salary = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$salary) {
    http_response_code(404);
    sendErrorMessage("Salary not found", 404);
}

$empStmt = $pdo->prepare("SELECT CONCAT(firstname, ' ', lastname, ' ', COALESCE(surname, '')) AS name FROM employees WHERE id = ?");
$empStmt->execute([$salary['employee_id']]);
$employeeName = $empStmt->fetchColumn();

$componentsStmt = $pdo->prepare("
    SELECT sd.id, sc.description, sc.type, sd.amount 
    FROM salary_details sd 
    JOIN salary_components sc ON sd.salary_component_id = sc.id 
    WHERE sd.salary_id = ?
");
$componentsStmt->execute([$salary['id']]);
$components = $componentsStmt->fetchAll(PDO::FETCH_ASSOC);

$data = [
    'id' => $salary['id'],
    'name' => $employeeName,
    'month' => $salary['month'],
    'year' => $salary['year'],
    'paid_on' => $salary['paid_on'],
    'gross' => $salary['gross'],
    'deduction' => $salary['deduction'],
    'net' => $salary['net'],
    'components' => array_map(function($c) {
        return [
            'id' => $c['id'],
            'description' => $c['description'],
            'type' => $c['type'] == 1 ? 'earning' : 'deduction',
            'amount' => $c['amount']
        ];
    }, $components)
];

ob_end_clean();
http_response_code(200);
header('Content-Type: application/json');
echo json_encode(["status" => "success", "data" => $data]);
exit;
?>