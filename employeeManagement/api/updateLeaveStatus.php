<?php
require_once './utils/db.php';
require_once './utils/response.php';

$token = $_POST['token'] ?? null;
$leave_id = $_POST['leave_id'] ?? null;
$status = $_POST['status'] ?? null;

if (!$token || !$leave_id || !$status) {
    sendErrorMessage("Missing required parameters", 400);
}

if (!in_array($status, ['Approved', 'Rejected'])) {
    sendErrorMessage("Invalid status", 400);
}

$pdo = getPDO();

// Verify token (assuming admin token validation)
$stmt = $pdo->prepare("SELECT * FROM admin WHERE token = ?");
$stmt->execute([$token]);
if (!$stmt->fetch()) {
    sendErrorMessage("Unauthorized", 401);
}

// Update leave status
$stmt = $pdo->prepare("UPDATE leave_requests SET status = ? WHERE id = ?");
$result = $stmt->execute([$status, $leave_id]);

if ($result) {
    sendSuccessMessage(['status' => 'success', 'message' => "Leave request $status successfully"]);
} else {
    sendErrorMessage("Failed to update leave status", 500);
}
?>