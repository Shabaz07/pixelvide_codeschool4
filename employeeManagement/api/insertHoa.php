<?php
ob_start();
require_once './utils/db.php';
require_once './utils/response.php';

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(404);
    sendErrorMessage("Invalid Method", 404);
}

$required_fields = ["token", "hod", "year", "mjH", "smjH", "mnH", "gsH", "sH", "dH", "sdH", "estScheme", "status"];
foreach ($required_fields as $field) {
    if (!isset($_POST[$field])) {
        http_response_code(400);
        sendErrorMessage("Missing required field: $field", 400);
    }
}

$token = $_POST['token'];
$hod = $_POST['hod'];
$year = $_POST['year'];
$estScheme = $_POST['estScheme'];
$mjH = $_POST['mjH'];
$smjH = $_POST['smjH'];
$mnH = $_POST['mnH'];
$gsH = $_POST['gsH'];
$sH = $_POST['sH'];
$dH = $_POST['dH'];
$sdH = $_POST['sdH'];
$scheme_code = $_POST['estScheme'];
$status = $_POST['status'];
$amount = 0;
$hoa = "{$mjH}{$smjH}{$mnH}{$gsH}{$sH}{$dH}{$sdH}";
$hoa_tier = "{$mjH}-{$smjH}-{$mnH}-{$gsH}-{$sH}-{$dH}-{$sdH}-{$scheme_code}";
$hoa = $hoa_tier;

$pdo = getPDO();

$stmt = $pdo->prepare("SELECT * FROM admin WHERE token = ?");
$stmt->execute([$token]);
if (!$stmt->fetch()) {
    http_response_code(401);
    sendErrorMessage("Token invalid", 401);
}

$query = "INSERT INTO hoa (hod, estScheme, hoa, hoa_tier, mjH, smjH, mnH, gsH, sH, dH, sdH, scheme_code, year, amount, status)
          VALUES (:hod, :estScheme, :hoa, :hoa_tier, :mjH, :smjH, :mnH, :gsH, :sH, :dH, :sdH, :scheme_code, :year, :amount, :status)";
$stmt = $pdo->prepare($query);

try {
    $stmt->execute([
        ':hod' => $hod,
        ':estScheme' => $estScheme,
        ':hoa' => $hoa,
        ':hoa_tier' => $hoa_tier,
        ':mjH' => $mjH,
        ':smjH' => $smjH,
        ':mnH' => $mnH,
        ':gsH' => $gsH,
        ':sH' => $sH,
        ':dH' => $dH,
        ':sdH' => $sdH,
        ':scheme_code' => $scheme_code,
        ':year' => $year,
        ':amount' => $amount,
        ':status' => $status
    ]);
    sendSuccessMessage("HOA added successfully",$stmt);
} catch (PDOException $e) {
    print_r($e->getMessage(). ' filename '.$e->getFile(). ' at line no :'.$e->getLine());
    sendErrorMessage("Database error: " . $e->getMessage(), 500);
}
?>
