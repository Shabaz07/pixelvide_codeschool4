<?php
require_once __DIR__ . ('\\response.php');


const DB_HOST = "localhost";
const DB_PORT = 5432;
const DB_NAME = "employee_management";
const DB_USERNAME = "postgres";
const DB_PASSWORD = 'postgres';

function getPDO()
{
    try {
        $dsn = "pgsql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME;
        $pdo = new PDO($dsn, DB_USERNAME, DB_PASSWORD, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        return $pdo;
    } catch (PDOException $e) {
        sendErrorMessage("Database Connection Error", 500);
    }
}