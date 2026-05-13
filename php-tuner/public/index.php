<?php
declare(strict_types=1);
require __DIR__ . '/../src/bootstrap.php';

$session = require_admin($ENV);
$csrf = csrf_token($session['id'], $ENV['SESSION_SECRET']);

$status = null;
$statusKind = null;  // 'ok' | 'err'

// --- POST: save a single row ---------------------------------
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'POST') {
    $token = (string)($_POST['csrf'] ?? '');
    if (!verify_csrf($ENV, $session['id'], $token)) {
        http_response_code(400);
        $status = 'Bad CSRF token. Refresh and try again.';
        $statusKind = 'err';
    } else {
        $bid = (string)($_POST['beach_id'] ?? '');
        $act = (string)($_POST['activity'] ?? '');
        $bias = (int)($_POST['bias'] ?? 0);
        $prohibited = isset($_POST['prohibited']) ? 1 : 0;
        $prohibitedReason = trim((string)($_POST['prohibited_reason'] ?? ''));
        // Reasons: textarea, one reason per line.
        $reasonsRaw = (string)($_POST['reasons'] ?? '');
        $reasons = array_values(array_filter(array_map('trim', explode("\n", $reasonsRaw))));

        if (!isset(BEACH_LABELS[$bid]) || !isset(ACTIVITIES[$act])) {
            $status = 'Unknown beach or activity.';
            $statusKind = 'err';
        } elseif ($bias < -50 || $bias > 100) {
            $status = 'Bias must be between -50 and +100.';
            $statusKind = 'err';
        } else {
            try {
                $db = db($ENV);
                // Capture the previous values for the audit log.
                $prev = $db->prepare(
                    'SELECT bias, prohibited FROM beach_biases
                      WHERE beach_id = :b AND activity = :a'
                );
                $prev->execute([':b' => $bid, ':a' => $act]);
                $prevRow = $prev->fetch() ?: null;

                $stmt = $db->prepare(
                    'INSERT INTO beach_biases
                        (beach_id, activity, bias, reasons, prohibited, prohibited_reason, updated_by_ip)
                     VALUES (:b, :a, :bias, :reasons, :proh, :pr, :ip)
                     ON DUPLICATE KEY UPDATE
                        bias = VALUES(bias),
                        reasons = VALUES(reasons),
                        prohibited = VALUES(prohibited),
                        prohibited_reason = VALUES(prohibited_reason),
                        updated_by_ip = VALUES(updated_by_ip)'
                );
                $stmt->execute([
                    ':b'       => $bid,
                    ':a'       => $act,
                    ':bias'    => $bias,
                    ':reasons' => json_encode($reasons, JSON_UNESCAPED_UNICODE),
                    ':proh'    => $prohibited,
                    ':pr'      => $prohibitedReason !== '' ? $prohibitedReason : null,
                    ':ip'      => $_SERVER['REMOTE_ADDR'] ?? null,
                ]);

                // Audit log.
                $aud = $db->prepare(
                    'INSERT INTO bias_audit
                        (beach_id, activity, bias_before, bias_after, prohibited_before, prohibited_after, changed_ip)
                     VALUES (:b, :a, :bb, :ba, :pb, :pa, :ip)'
                );
                $aud->execute([
                    ':b'  => $bid,
                    ':a'  => $act,
                    ':bb' => $prevRow['bias'] ?? null,
                    ':ba' => $bias,
                    ':pb' => $prevRow ? (int)$prevRow['prohibited'] : null,
                    ':pa' => $prohibited,
                    ':ip' => $_SERVER['REMOTE_ADDR'] ?? null,
                ]);

                $status = sprintf(
                    'Saved %s × %s.',
                    BEACH_LABELS[$bid],
                    ACTIVITIES[$act]
                );
                $statusKind = 'ok';
            } catch (Throwable $e) {
                $status = 'Save failed: database error.';
                $statusKind = 'err';
            }
        }
    }
}

// --- Read all biases ------------------------------------------
$rows = db($ENV)->query(
    'SELECT beach_id, activity, bias, reasons, prohibited, prohibited_reason, updated_at
       FROM beach_biases'
)->fetchAll();

$byKey = [];
foreach ($rows as $r) {
    $byKey[$r['beach_id']][$r['activity']] = $r;
}

// Restrict to a specific beach if user clicked one.
$focusBeach = (string)($_GET['beach'] ?? '');
if ($focusBeach !== '' && !isset(BEACH_LABELS[$focusBeach])) $focusBeach = '';
?><!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Beach Aware tuner — Devstars Jersey</title>
<style>
  :root {
    --bg: #f7f8fa; --card: #fff; --fg: #111827; --muted: #6b7280;
    --border: #e5e7eb; --accent: #111827; --ok: #047857; --err: #b91c1c;
    color-scheme: light;
  }
  body { font: 14px/1.5 system-ui, sans-serif; background: var(--bg); color: var(--fg); margin: 0; }
  header { background: #111827; color: #fff; padding: .9rem 1.25rem; display: flex; align-items: center; gap: 1rem; }
  header h1 { font-size: 1rem; margin: 0; font-weight: 600; }
  header .spacer { flex: 1; }
  header a { color: #cbd5e1; text-decoration: none; }
  header a:hover { color: #fff; }
  main { max-width: 1100px; margin: 0 auto; padding: 1.5rem 1.25rem 4rem; }
  .toast { padding: .65rem .85rem; border-radius: 8px; margin-bottom: 1.25rem; font-size: .92rem; }
  .toast.ok  { background: #ecfdf5; color: var(--ok); border: 1px solid #a7f3d0; }
  .toast.err { background: #fef2f2; color: var(--err); border: 1px solid #fecaca; }
  .nav { display: flex; flex-wrap: wrap; gap: .35rem; margin-bottom: 1.5rem; }
  .nav a { padding: .3rem .65rem; border-radius: 999px; font-size: .82rem; background: #fff; border: 1px solid var(--border); color: var(--fg); text-decoration: none; }
  .nav a.active { background: var(--accent); color: #fff; border-color: var(--accent); }
  .beach { background: var(--card); border: 1px solid var(--border); border-radius: 12px; margin-bottom: 1.5rem; overflow: hidden; }
  .beach h2 { margin: 0; padding: .85rem 1rem; font-size: 1rem; background: #f9fafb; border-bottom: 1px solid var(--border); }
  table { width: 100%; border-collapse: collapse; }
  th, td { padding: .55rem .75rem; text-align: left; border-top: 1px solid var(--border); vertical-align: top; font-size: .9rem; }
  th { font-weight: 500; color: var(--muted); background: #fafbfc; }
  td.activity { font-weight: 500; min-width: 7rem; }
  td.bias { width: 9rem; }
  td.bias input[type=number] { width: 4rem; padding: .25rem .35rem; border: 1px solid var(--border); border-radius: 6px; font: inherit; }
  td.bias .hint { color: var(--muted); font-size: .75rem; margin-top: .15rem; }
  td.reasons textarea { width: 100%; min-height: 2.5rem; font: inherit; padding: .3rem .45rem; border: 1px solid var(--border); border-radius: 6px; box-sizing: border-box; resize: vertical; }
  td.proh label { display: flex; align-items: center; gap: .4rem; font-size: .82rem; white-space: nowrap; }
  td.proh input[type=text] { width: 100%; margin-top: .35rem; padding: .25rem .4rem; border: 1px solid var(--border); border-radius: 6px; font: inherit; }
  td.save { white-space: nowrap; width: 1%; }
  td.save button { padding: .35rem .75rem; background: var(--accent); color: #fff; border: 0; border-radius: 6px; font: inherit; cursor: pointer; }
  td.save button:hover { background: #000; }
  .scale { color: var(--muted); font-size: .78rem; margin: -0.75rem 0 1.5rem; }
  .scale b { color: var(--fg); }
  details.help { background: #fff; border: 1px solid var(--border); border-radius: 8px; padding: .65rem .9rem; margin-bottom: 1.5rem; }
  details.help summary { cursor: pointer; font-weight: 500; }
  details.help p { margin: .5rem 0 0; color: var(--muted); font-size: .9rem; }
</style>
</head>
<body>

<header>
  <h1>Devstars Jersey — Beach Aware tuner</h1>
  <span style="font-size:.8rem;color:#94a3b8">v1.0 · admin</span>
  <span class="spacer"></span>
  <a href="/tuner/api.php" target="_blank">API output</a>
  <a href="/tuner/logout.php">Sign out</a>
</header>

<main>

<?php if ($status): ?>
  <div class="toast <?= $statusKind === 'ok' ? 'ok' : 'err' ?>"><?= h($status) ?></div>
<?php endif; ?>

<details class="help">
  <summary>How tuning works</summary>
  <p>
    Each row adjusts how a beach scores for one activity. <b>Bias</b> is added
    to the physics-based hazard score (0–100, lower is safer). Negative values
    make the beach look <em>better</em>, positive values make it look
    <em>worse</em>. Typical range is &minus;30 to +70. Use the
    <b>Prohibited</b> toggle to force-rank the beach last for that activity
    (e.g. "no kitesurfing allowed here"). One reason per line in the reasons
    box — these show up in the "Why this score" panel on the live app.
    Changes are picked up by the front-end on its next page load.
  </p>
</details>

<nav class="nav">
  <a href="/tuner/" class="<?= $focusBeach === '' ? 'active' : '' ?>">All beaches</a>
  <?php foreach (BEACH_LABELS as $bid => $bname): ?>
    <a href="/tuner/?beach=<?= h($bid) ?>" class="<?= $focusBeach === $bid ? 'active' : '' ?>"><?= h($bname) ?></a>
  <?php endforeach; ?>
</nav>

<p class="scale">
  <b>Scale:</b> &minus;30 (much better than physics says) … 0 (no override) … +70 (much worse).
  Out of range values will be rejected.
</p>

<?php
$beachesToShow = $focusBeach !== '' ? [$focusBeach => BEACH_LABELS[$focusBeach]] : BEACH_LABELS;
foreach ($beachesToShow as $bid => $bname):
?>
  <section class="beach">
    <h2><?= h($bname) ?></h2>
    <table>
      <thead>
        <tr>
          <th>Activity</th>
          <th>Bias</th>
          <th>Reasons (one per line)</th>
          <th>Prohibited?</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <?php foreach (ACTIVITIES as $aid => $aname):
          $row = $byKey[$bid][$aid] ?? null;
          $bias = $row ? (int)$row['bias'] : 0;
          $reasonsArr = $row ? (json_decode($row['reasons'] ?? '[]', true) ?: []) : [];
          $reasonsText = implode("\n", $reasonsArr);
          $proh = $row ? (int)$row['prohibited'] === 1 : false;
          $prohReason = $row['prohibited_reason'] ?? '';
          $formId = 'f_' . $bid . '_' . $aid;
        ?>
        <tr>
          <td class="activity">
            <?= h($aname) ?>
            <!-- Each row is its own form. The <form> sits above the table
                 row so it isn't an invalid child of <tbody>; the inputs
                 below reference it by id via the `form` attribute. -->
            <form id="<?= h($formId) ?>" method="post" action="/tuner/<?= $focusBeach !== '' ? '?beach=' . h($focusBeach) : '' ?>">
              <input type="hidden" name="csrf"     value="<?= h($csrf) ?>" form="<?= h($formId) ?>">
              <input type="hidden" name="beach_id" value="<?= h($bid) ?>"  form="<?= h($formId) ?>">
              <input type="hidden" name="activity" value="<?= h($aid) ?>"  form="<?= h($formId) ?>">
            </form>
          </td>
          <td class="bias">
            <input type="number" name="bias" min="-50" max="100" value="<?= h((string)$bias) ?>" form="<?= h($formId) ?>">
            <div class="hint"><?= $bias < 0 ? 'safer' : ($bias > 0 ? 'riskier' : 'neutral') ?></div>
          </td>
          <td class="reasons">
            <textarea name="reasons" rows="2" placeholder="e.g. Locally regarded as a good family swim spot" form="<?= h($formId) ?>"><?= h($reasonsText) ?></textarea>
          </td>
          <td class="proh">
            <label>
              <input type="checkbox" name="prohibited" <?= $proh ? 'checked' : '' ?> form="<?= h($formId) ?>">
              Force-rank last
            </label>
            <input type="text" name="prohibited_reason" placeholder="Reason shown to users" value="<?= h($prohReason) ?>" form="<?= h($formId) ?>">
          </td>
          <td class="save">
            <button type="submit" form="<?= h($formId) ?>">Save</button>
          </td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </section>
<?php endforeach; ?>

</main>
</body>
</html>
