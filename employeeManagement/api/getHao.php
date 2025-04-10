<?php
ob_start();
require_once './utils/db.php';
require_once './utils/response.php';

if ($_SERVER["REQUEST_METHOD"] !== "GET") {
    http_response_code(404);
    sendErrorMessage("Invalid Method", 404);
}

$required_fields = ["token"];
foreach ($required_fields as $field) {
    if (!isset($_GET[$field])) {
        http_response_code(400);
        sendErrorMessage("Missing required field: $field", 400);
    }
}

$token = $_GET['token'];


$pdo = getPDO();

$stmt = $pdo->prepare("SELECT * FROM admin WHERE token = ?");
$stmt->execute([$token]);
if (!$stmt->fetch()) {
    http_response_code(401);
    sendErrorMessage("Token invalid", 401);
}

$query =  "SELECT 
            hoa.id,
            d.description AS hod_description, 
            s.description AS estScheme_description, 
            CONCAT(hoa.mjH, hoa.smjH, hoa.mnH, hoa.gsH, hoa.sH, hoa.dH, hoa.sdH) AS hoa,
            CONCAT(hoa.mjH, '-', hoa.smjH, '-', hoa.mnH, '-', hoa.gsH, '-', hoa.sH, '-', hoa.dH, '-', hoa.sdH,'-',s.code) AS hoa_tier,  
            hoa.mjH,
            hoa.smjH,
            hoa.mnH,
            hoa.gsH,
            hoa.sH,
            hoa.dH,
            hoa.sdH,
            s.description,
            hoa.year,
            hoa.amount,
            hoa.status
        FROM 
            hoa
        JOIN 
            department d ON hoa.hod = d.id
        JOIN 
            scheme s ON hoa.estScheme = s.id;";
$stmt = $pdo->prepare($query);

$stmt->execute();
$hoa = $stmt->fetchAll(PDO::FETCH_ASSOC);

sendSuccessMessage("success", $hoa);
?>
