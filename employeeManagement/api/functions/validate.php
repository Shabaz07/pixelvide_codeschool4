<?php

require_once(__DIR__ . '\..\utils\response.php');
require_once(__DIR__ . '\..\utils\db.php');

function validateToken()
{
    $headers = apache_request_headers();
    $token = $headers['Authorization'];

    if (!$token) {
        sendErrorMessage("Token Not Found", 401);
    }

    $pdo = getPDO();
    $query = "SELECT * FROM users WHERE token = :token";
    $stmt = $pdo->prepare($query);
    $stmt->bindParam('token', $token);
    $stmt->execute();

    $userDetails = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$userDetails) {
        sendErrorMessage("Invalid Token", 401);
    }

    return $userDetails;
}
