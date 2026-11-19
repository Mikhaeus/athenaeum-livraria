<?php
declare(strict_types=1);
function db(): PDO {
    static $pdo = null;
    if ($pdo instanceof PDO) return $pdo;
    $host = '127.0.0.1'; $dbname = 'athenaeum_livraria'; $user = 'root'; $pass = '';
    try {
        $pdo = new PDO("mysql:host={$host};dbname={$dbname};charset=utf8mb4", $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
        return $pdo;
    } catch (PDOException $e) {
        error_log('Falha PDO: '.$e->getMessage());
        http_response_code(500);
        exit('Não foi possível conectar ao banco Athenaeum. Confira se o MySQL está ativo e se banco.sql foi importado.');
    }
}
