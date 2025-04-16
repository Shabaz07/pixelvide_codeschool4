<?php
require_once './utils/db.php';
require_once './utils/response.php';

$token = $_GET['token'] ?? null;

if (!$token) {
    sendErrorMessage("Token is required", 400);
}

$pdo = getPDO();
$stmt = $pdo->prepare("SELECT * FROM admin WHERE token = ?");
$stmt->execute([$token]);
if (!$stmt->fetch()) {
    sendErrorMessage("Unauthorized", 401);
}

// Total Employees
$totalStmt = $pdo->query("SELECT COUNT(*) as total FROM employees");
$totalEmployees = $totalStmt->fetch(PDO::FETCH_ASSOC)['total'];

// Average Monthly Salary (overall, 2025 data)
$avgMonthlyStmt = $pdo->query("SELECT AVG(gross) as avg_monthly FROM salaries WHERE year = 2025");
$avgMonthlySalary = $avgMonthlyStmt->fetch(PDO::FETCH_ASSOC)['avg_monthly'] ?? 0;

// Average Yearly Salary (overall, using December 2024 as proxy)
$avgYearlyStmt = $pdo->query("SELECT AVG(gross * 12) as avg_yearly FROM salaries WHERE year = 2024 AND month = 12");
$avgYearlySalary = $avgYearlyStmt->fetch(PDO::FETCH_ASSOC)['avg_yearly'] ?? 0;

// Average Monthly Salary by Role (2025)
$monthlyByRoleStmt = $pdo->query("
    SELECT 
        d.description AS role, 
        COUNT(DISTINCT e.id) AS employee_count, 
        AVG(s.gross) AS avg_monthly_salary 
    FROM employees e
    JOIN designations d ON e.designation_id = d.id
    JOIN salaries s ON e.id = s.employee_id
    WHERE s.year = 2025
    GROUP BY d.description
");
$monthlyByRole = $monthlyByRoleStmt->fetchAll(PDO::FETCH_ASSOC) ?? [];

// Average Monthly Salary by Location (2025)
$monthlyByLocationStmt = $pdo->query("
    SELECT 
        l.district AS location, 
        COUNT(DISTINCT e.id) AS employee_count, 
        AVG(s.gross) AS avg_monthly_salary 
    FROM employees e
    JOIN location l ON e.location_id = l.id
    JOIN salaries s ON e.id = s.employee_id
    WHERE s.year = 2025
    GROUP BY l.district
");
$monthlyByLocation = $monthlyByLocationStmt->fetchAll(PDO::FETCH_ASSOC) ?? [];

// Average Yearly Salary by Role (2024, December data as proxy)
$yearlyByRoleStmt = $pdo->query("
    SELECT 
        d.description AS role, 
        COUNT(DISTINCT e.id) AS employee_count, 
        AVG(s.gross * 12) AS avg_yearly_salary 
    FROM employees e
    JOIN designations d ON e.designation_id = d.id
    JOIN salaries s ON e.id = s.employee_id
    WHERE s.year = 2024 AND s.month = 12
    GROUP BY d.description
");
$yearlyByRole = $yearlyByRoleStmt->fetchAll(PDO::FETCH_ASSOC) ?? [];

// Average Yearly Salary by Location (2024, December data as proxy)
$yearlyByLocationStmt = $pdo->query("
    SELECT 
        l.district AS location, 
        COUNT(DISTINCT e.id) AS employee_count, 
        AVG(s.gross * 12) AS avg_yearly_salary 
    FROM employees e
    JOIN location l ON e.location_id = l.id
    JOIN salaries s ON e.id = s.employee_id
    WHERE s.year = 2024 AND s.month = 12
    GROUP BY l.district
");
$yearlyByLocation = $yearlyByLocationStmt->fetchAll(PDO::FETCH_ASSOC) ?? [];

// Prepare response data
$responseData = [
    'totalEmployees' => $totalEmployees,
    'avgMonthlySalary' => number_format($avgMonthlySalary, 2),
    'avgYearlySalary' => number_format($avgYearlySalary, 2),
    'monthlyByRole' => $monthlyByRole,
    'monthlyByLocation' => $monthlyByLocation,
    'yearlyByRole' => $yearlyByRole,
    'yearlyByLocation' => $yearlyByLocation
];

// Debugging: Log the raw data before sending
error_log("Raw Response Data: " . json_encode($responseData));

// Send response (assuming sendSuccessMessage wraps it in {status: true, message: {...}, data: null})
sendSuccessMessage(['status' => 'success', 'data' => $responseData]);
?>