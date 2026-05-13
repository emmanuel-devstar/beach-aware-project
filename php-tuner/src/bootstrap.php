<?php
// Devstars Jersey Beach Aware — bootstrap.
// Loaded by every entry point in /public.

declare(strict_types=1);

// --- Locate project root (parent of /public) ---
if (!defined('APP_ROOT')) {
    define('APP_ROOT', dirname(__DIR__));
}

// --- Minimal .env loader (no Composer) -----------------------
function load_env(string $path): array {
    if (!is_readable($path)) {
        throw new RuntimeException("Cannot read .env at $path");
    }
    $out = [];
    foreach (file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        if (!str_contains($line, '=')) continue;
        [$k, $v] = explode('=', $line, 2);
        $k = trim($k);
        $v = trim($v);
        // strip surrounding quotes if present
        if (strlen($v) >= 2 && ($v[0] === '"' || $v[0] === "'") && $v[strlen($v)-1] === $v[0]) {
            $v = substr($v, 1, -1);
        }
        $out[$k] = $v;
    }
    return $out;
}

$ENV = load_env(APP_ROOT . '/.env');

// --- Sanity checks -------------------------------------------
foreach (['DB_HOST','DB_NAME','DB_USER','DB_PASS','ADMIN_PASSWORD_HASH','SESSION_SECRET'] as $k) {
    if (!isset($ENV[$k]) || $ENV[$k] === '') {
        http_response_code(500);
        // Don't leak which key. Generic message.
        exit('Server configuration incomplete. Check .env.');
    }
}

// --- PDO connection ------------------------------------------
function db(array $ENV): PDO {
    static $pdo = null;
    if ($pdo) return $pdo;
    $dsn = sprintf(
        'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
        $ENV['DB_HOST'], $ENV['DB_PORT'] ?? '3306', $ENV['DB_NAME']
    );
    $pdo = new PDO($dsn, $ENV['DB_USER'], $ENV['DB_PASS'], [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ]);
    return $pdo;
}

// --- Session helpers -----------------------------------------
// We use a server-side `admin_sessions` table keyed by an opaque
// 32-byte random token. The client only gets a cookie. In production
// we use the `__Host-` prefix (requires Secure + path=/ + no Domain).
// In dev (PRODUCTION=0) we fall back to a normal cookie name because
// `__Host-` cookies are rejected over plain HTTP.
function session_cookie_name(array $ENV): string {
    return (($ENV['PRODUCTION'] ?? '1') === '1') ? '__Host-tuner_sid' : 'tuner_sid';
}

function current_session(array $ENV): ?array {
    $cookie = $_COOKIE[session_cookie_name($ENV)] ?? null;
    if (!$cookie || !preg_match('/^[a-f0-9]{64}$/', $cookie)) return null;
    $stmt = db($ENV)->prepare(
        'SELECT id, expires_at FROM admin_sessions
          WHERE id = :id AND expires_at > NOW() LIMIT 1'
    );
    $stmt->execute([':id' => $cookie]);
    $row = $stmt->fetch();
    return $row ?: null;
}

function require_admin(array $ENV): array {
    $s = current_session($ENV);
    if (!$s) {
        // For HTML pages, redirect to login.
        // For JSON endpoints the caller should check first.
        header('Location: /tuner/login.php');
        exit;
    }
    return $s;
}

function start_session(array $ENV): string {
    $sid = bin2hex(random_bytes(32));
    $hours = (int)($ENV['SESSION_HOURS'] ?? 12);
    $stmt = db($ENV)->prepare(
        'INSERT INTO admin_sessions (id, expires_at, ip)
         VALUES (:id, DATE_ADD(NOW(), INTERVAL :h HOUR), :ip)'
    );
    $stmt->execute([
        ':id' => $sid,
        ':h'  => $hours,
        ':ip' => $_SERVER['REMOTE_ADDR'] ?? null,
    ]);
    $secure = ($ENV['PRODUCTION'] ?? '1') === '1';
    setcookie(session_cookie_name($ENV), $sid, [
        'expires'  => time() + $hours * 3600,
        'path'     => '/',
        'secure'   => $secure,
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    return $sid;
}

function end_session(array $ENV): void {
    $name = session_cookie_name($ENV);
    $cookie = $_COOKIE[$name] ?? null;
    if ($cookie && preg_match('/^[a-f0-9]{64}$/', $cookie)) {
        $stmt = db($ENV)->prepare('DELETE FROM admin_sessions WHERE id = :id');
        $stmt->execute([':id' => $cookie]);
    }
    setcookie($name, '', [
        'expires' => time() - 3600,
        'path'    => '/',
        'secure'  => ($ENV['PRODUCTION'] ?? '1') === '1',
        'httponly'=> true,
        'samesite'=> 'Lax',
    ]);
}

// --- CSRF -----------------------------------------------------
// Double-submit pattern: stash a token derived from SESSION_SECRET + sid.
function csrf_token(string $sid, string $secret): string {
    return hash_hmac('sha256', $sid, $secret);
}
function verify_csrf(array $ENV, string $sid, ?string $given): bool {
    return is_string($given) && hash_equals(csrf_token($sid, $ENV['SESSION_SECRET']), $given);
}

// --- HTML helpers --------------------------------------------
function h(?string $s): string {
    return htmlspecialchars((string)$s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

// --- Activity & beach metadata (display only) ----------------
const ACTIVITIES = [
    'swimming'       => 'Sea swimming',
    'paddling'       => 'Paddling (kids)',
    'paddleboarding' => 'Paddle board',
    'kayaking'       => 'Kayak',
    'surfing'        => 'Surf',
    'bodyboarding'   => 'Body board',
    'kitesurfing'    => 'Kite surf',
    'sailing'        => 'Sail',
];

const BEACH_LABELS = [
    'ouaisne'             => 'Ouaisné',
    'green-island'        => 'Green Island',
    'st-ouens'            => "St Ouen's Bay",
    'plemont'             => 'Plémont',
    'greve-de-lecq'       => 'Grève de Lecq',
    'bonne-nuit'          => 'Bonne Nuit',
    'bouley-bay'          => 'Bouley Bay',
    'rozel'               => 'Rozel',
    'st-catherines'       => "St Catherine's Bay",
    'archirondel'         => 'Archirondel',
    'anne-port'           => 'Anne Port',
    'royal-bay-grouville' => 'Royal Bay (Grouville)',
    'havre-des-pas'       => 'Havre des Pas',
    'st-brelades'         => "St Brelade's Bay",
    'beauport'            => 'Beauport',
    'portelet'            => 'Portelet',
];
