<?php
ob_start();
require_once './utils/db.php';
require_once './utils/response.php';

if ($_SERVER["REQUEST_METHOD"] !== "GET") {
    http_response_code(404);
    sendErrorMessage("Invalid Method", 404);
}

if (!isset($_GET["token"])) {
    http_response_code(400);
    sendErrorMessage("Token is required", 400);
}

$token = $_GET['token'];
$pdo = getPDO();

// Verify token
$stmt = $pdo->prepare("SELECT * FROM admin WHERE token = ?");
$stmt->execute([$token]);
if (!$stmt->fetch()) {
    http_response_code(401);
    sendErrorMessage("Token invalid", 401);
}

if (isset($_GET["salary_id"]) || (isset($_GET["employee_id"]) && isset($_GET["month"]) && isset($_GET["year"]))) {
    $salary_id = $_GET["salary_id"] ?? null;
    $employee_id = $_GET["employee_id"] ?? null;
    $month = $_GET["month"] ?? null;
    $year = $_GET["year"] ?? null;

    $query = "
        SELECT 
            s.id AS salary_id,
            CONCAT(e.firstname, ' ', e.lastname, ' ', COALESCE(e.surname, '')) AS employee_name,
            s.month,
            s.year,
            s.paid_on,
            s.gross,
            s.deduction,
            s.net,
            s.created_at
        FROM salaries s
        JOIN employees e ON s.employee_id = e.id
        WHERE ";
    
    if ($salary_id) {
        $query .= "s.id = ?";
    } else {
        $query .= "s.employee_id = ? AND s.month = ? AND s.year = ?";
    }

    $stmt = $pdo->prepare($query);
    if ($salary_id) {
        $stmt->execute([$salary_id]);
    } else {
        $stmt->execute([$employee_id, $month, $year]);
    }
    $salary = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$salary) {
        http_response_code(404);
        sendErrorMessage("Salary record not found", 404);
    }

    $earningsQuery = "
        SELECT sd.id, sc.description, sd.amount
        FROM salary_details sd
        JOIN salary_components sc ON sd.salary_component_id = sc.id
        WHERE sd.salary_id = ? AND sc.type = 1
    ";
    $earningsStmt = $pdo->prepare($earningsQuery);
    $earningsStmt->execute([$salary["salary_id"]]);
    $earnings = $earningsStmt->fetchAll(PDO::FETCH_ASSOC);

    $deductionsQuery = "
        SELECT sd.id, sc.description, sd.amount
        FROM salary_details sd
        JOIN salary_components sc ON sd.salary_component_id = sc.id
        WHERE sd.salary_id = ? AND sc.type = 2
    ";
    $deductionsStmt = $pdo->prepare($deductionsQuery);
    $deductionsStmt->execute([$salary["salary_id"]]);
    $deductions = $deductionsStmt->fetchAll(PDO::FETCH_ASSOC);

    $components = array_merge(
        array_map(function($e) { return ['id' => $e['id'], 'description' => $e['description'], 'amount' => $e['amount'], 'type' => 'earning']; }, $earnings),
        array_map(function($d) { return ['id' => $d['id'], 'description' => $d['description'], 'amount' => $d['amount'], 'type' => 'deduction']; }, $deductions)
    );

    $salaryData = [
        "id" => $salary["salary_id"],
        "name" => $salary["employee_name"],
        "month" => $salary["month"],
        "year" => $salary["year"],
        "gross" => $salary["gross"],
        "deduction" => $salary["deduction"],
        "net" => $salary["net"],
        "components" => $components
    ];

    ob_end_clean();
    http_response_code(200);
    header('Content-Type: application/json');
    echo json_encode(["status" => "success", "data" => $salaryData]);
    exit;
} else {
    $query = "
        SELECT 
            e.id,
            s.id AS salary_id,
            CONCAT(e.firstname, ' ', e.lastname, ' ', COALESCE(e.surname, '')) AS name,
            s.month,
            s.year,
            s.paid_on,
            s.gross,
            s.deduction,
            s.net,
            s.created_at
        FROM salaries s
        JOIN employees e ON s.employee_id = e.id
        WHERE s.paid_on >= NOW() - INTERVAL '1 MONTH'
        ORDER BY e.id ASC
    ";
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $salaries = $stmt->fetchAll(PDO::FETCH_ASSOC);

    ob_end_clean();
    http_response_code(200);
    header('Content-Type: application/json');
    echo json_encode(["status" => "success", "data" => $salaries]);
    exit;
}
?>