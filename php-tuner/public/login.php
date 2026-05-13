<?php
declare(strict_types=1);
require __DIR__ . '/../src/bootstrap.php';

$error = null;

if (($_SERVER['REQUEST_METHOD'] ?? '') === 'POST') {
    $pw = (string)($_POST['password'] ?? '');
    // Tiny rate limit: 500 ms per attempt to slow brute force on a single IP.
    usleep(500_000);
    if ($pw !== '' && password_verify($pw, $ENV['ADMIN_PASSWORD_HASH'])) {
        start_session($ENV);
        header('Location: /tuner/');
        exit;
    }
    $error = 'Wrong password.';
}

// If already logged in, skip the form.
if (current_session($ENV)) {
    header('Location: /tuner/');
    exit;
}
?><!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Sign in — Beach Aware tuner</title>
<style>
  :root { color-scheme: light dark; }
  body { font: 15px/1.5 system-ui, sans-serif; background: #f7f8fa; margin: 0; min-height: 100vh; display: grid; place-items: center; }
  .card { background: #fff; padding: 2rem 2.25rem; border-radius: 12px; box-shadow: 0 1px 2px rgba(0,0,0,.05), 0 8px 24px rgba(0,0,0,.05); width: min(380px, 92vw); }
  h1 { font-size: 1.1rem; margin: 0 0 1.25rem; font-weight: 600; }
  label { display: block; font-size: .85rem; margin-bottom: .25rem; color: #555; }
  input[type=password] { width: 100%; box-sizing: border-box; padding: .55rem .7rem; font-size: 1rem; border: 1px solid #d1d5db; border-radius: 8px; }
  input[type=password]:focus { outline: 2px solid #2563eb33; border-color: #2563eb; }
  button { margin-top: 1rem; width: 100%; padding: .6rem; background: #111827; color: #fff; border: 0; border-radius: 8px; font-weight: 500; cursor: pointer; }
  .err { color: #b91c1c; font-size: .9rem; margin-top: .75rem; }
  .meta { color: #6b7280; font-size: .8rem; margin-top: 1.25rem; }
</style>
</head>
<body>
<form class="card" method="post" autocomplete="off">
  <h1>Beach Aware tuner</h1>
  <label for="pw">Admin password</label>
  <input id="pw" type="password" name="password" autofocus required>
  <button type="submit">Sign in</button>
  <?php if ($error): ?><p class="err"><?= h($error) ?></p><?php endif; ?>
  <p class="meta">Session lasts <?= h((string)($ENV['SESSION_HOURS'] ?? '12')) ?> hours.</p>
</form>
</body>
</html>
