<?php

function sendErrorMessage($message = 'Something Went Wrong!', $status = 400)
{
    http_response_code($status);
    header('Content-Type: application/json');
    http_response_code($status);
    echo json_encode(["status" => false, "message" => $message, "data" => null]);
    exit;
}

function sendSuccessMessage($message = "success", $data = null)
{
    http_response_code(200);
    header('Content-Type: application/json');
    echo json_encode(["status" => true, "message" => $message, "data" => $data]);
    exit;
}

