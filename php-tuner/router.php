<?php
// Dev-only router for PHP's built-in server.
// Maps /tuner/<file>  ->  /public/<file>
// Maps /tuner/        ->  /public/index.php
// Anything else: 404.
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
if (strpos($uri, '/tuner') !== 0) {
    http_response_code(404);
    echo "Not found";
    return true;
}
$rest = substr($uri, strlen('/tuner'));
if ($rest === '' || $rest === '/') $rest = '/index.php';
$path = __DIR__ . '/public' . $rest;
if (is_file($path)) {
    if (substr($path, -4) === '.php') {
        require $path;
        return true;
    }
    return false; // let built-in server serve static
}
http_response_code(404);
echo "Not found";
return true;
