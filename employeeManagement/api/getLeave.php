<?php
require_once './utils/db.php';
require_once './utils/response.php';

$pdo = getPDO();
$stmt = $pdo->query("
    SELECT 
        id,
        employee_name,
        department,
        leave_type,
        from_date,
        to_date,
        days,
        reason,
        applied_on,
        status
    FROM leave_requests
");
$leaves = $stmt->fetchAll(PDO::FETCH_ASSOC);

if ($leaves) {
    sendSuccessMessage("success",$leaves);
} else {
    sendSuccessMessage(['status' => 'success', 'data' => []]);
}
?>