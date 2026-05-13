<?php
// Read-only JSON endpoint for the React app to fetch live bias overrides.
// Public — no auth required. Heavily cacheable.

declare(strict_types=1);
require __DIR__ . '/../src/bootstrap.php';

// CORS — allow either an explicit allow-list or any origin.
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$allowed = array_filter(array_map('trim', explode(',', $ENV['CORS_ORIGINS'] ?? '')));
if (!$allowed) {
    header('Access-Control-Allow-Origin: *');
} elseif (in_array($origin, $allowed, true)) {
    header('Access-Control-Allow-Origin: ' . $origin);
    header('Vary: Origin');
}
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') { http_response_code(204); exit; }

header('Content-Type: application/json; charset=utf-8');
// 5-minute browser cache, longer at CDN. Stale-while-revalidate keeps it snappy.
header('Cache-Control: public, max-age=300, stale-while-revalidate=600');

try {
    $rows = db($ENV)->query(
        'SELECT beach_id, activity, bias, reasons, prohibited, prohibited_reason, updated_at
           FROM beach_biases'
    )->fetchAll();
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['error' => 'database_unavailable'], JSON_UNESCAPED_UNICODE);
    exit;
}

// Shape the output as { biases: { beachId: { activity: {bias, reasons, prohibited?, prohibitedReason?} } } }
// so the React app can `Object.assign` it on top of the static data.
$out = ['updatedAt' => null, 'biases' => []];
foreach ($rows as $r) {
    $bid = $r['beach_id'];
    $act = $r['activity'];
    $entry = [
        'bias'    => (int)$r['bias'],
        'reasons' => json_decode($r['reasons'] ?? '[]', true) ?: [],
    ];
    if ((int)$r['prohibited'] === 1) {
        $entry['prohibited'] = true;
        if (!empty($r['prohibited_reason'])) {
            $entry['prohibitedReason'] = $r['prohibited_reason'];
        }
    }
    $out['biases'][$bid][$act] = $entry;
    if ($r['updated_at'] && $r['updated_at'] > ($out['updatedAt'] ?? '')) {
        $out['updatedAt'] = $r['updated_at'];
    }
}
echo json_encode($out, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
