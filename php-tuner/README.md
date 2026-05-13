# Devstars Jersey: Beach Aware — PHP Tuner

A small PHP + MySQL admin that lets you tune the per‑beach, per‑activity bias
values used by the React front-end. The static site fetches the latest values
from `api.php` at startup, caches them for 5 minutes, and falls back silently
to the values baked into the build if the API is unreachable.

```
php-tuner/
├── .env.example       — copy to .env and fill in real values
├── sql/schema.sql     — schema + seed data (68 rows, 16 beaches × 8 activities)
├── src/bootstrap.php  — PDO connection, sessions, CSRF, beach/activity labels
├── public/            — web root (point Nginx here)
│   ├── index.php      — admin UI (requires login)
│   ├── login.php      — password form
│   ├── logout.php     — clears session
│   └── api.php        — public read-only JSON for the React app
└── README.md          — this file
```

---

## 1. Database setup

Connect to your MySQL/MariaDB with a user that can create tables, then:

```bash
mysql -h HOST -u USER -p DBNAME < sql/schema.sql
```

This creates three tables — `beach_biases`, `admin_sessions`, `bias_audit` —
and inserts the 68 seed rows. Re-running the file is safe: the inserts use
`ON DUPLICATE KEY UPDATE` and won't overwrite tuned values.

---

## 2. Configuration

Copy `.env.example` to `.env` (sit it next to it, one directory above
`public/`), and fill in:

| Key                   | What to put there                                       |
| --------------------- | ------------------------------------------------------- |
| `DB_HOST`, `DB_PORT`  | MySQL host & port                                       |
| `DB_NAME`             | Database name                                           |
| `DB_USER`, `DB_PASS`  | A MySQL user that can SELECT/INSERT/UPDATE the 3 tables |
| `ADMIN_PASSWORD_HASH` | bcrypt hash — generate it on the server (see below)     |
| `SESSION_SECRET`      | 64 random bytes hex — generate on the server            |
| `SESSION_HOURS`       | Session lifetime, default 12                            |
| `CORS_ORIGINS`        | Comma-separated allowed origins, or blank to allow all  |
| `PRODUCTION`          | `1` on a real HTTPS deployment, `0` for local dev       |

Generate the two secrets on your server (never paste your real password into
the file):

```bash
php -r 'echo password_hash("PUT-YOUR-ADMIN-PASSWORD-HERE", PASSWORD_DEFAULT), PHP_EOL;'
php -r 'echo bin2hex(random_bytes(32)), PHP_EOL;'
```

Paste the first into `ADMIN_PASSWORD_HASH` and the second into
`SESSION_SECRET`. Then **delete your shell history** if you're paranoid.

Make sure `.env` is owned by the web user and `chmod 600`. Better: place it
*outside* `public/`. The bootstrap reads it from one directory up, which is
what the layout above gives you.

---

## 3. Nginx + PHP-FPM

A drop-in snippet you can add inside your existing `server { … }` block, so
the tuner lives at `https://yourhost/tuner/`:

```nginx
location /tuner/ {
    alias /var/www/devstars-beach-aware/php-tuner/public/;
    index index.php;
    try_files $uri $uri/ /tuner/index.php?$query_string;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;   # match your php-fpm version
        fastcgi_param SCRIPT_FILENAME $request_filename;
    }
}

# Don't serve the .env or src/ via Nginx
location ~ /\.env { deny all; return 404; }
location /tuner/src/ { deny all; return 404; }
location /tuner/sql/ { deny all; return 404; }
```

Reload Nginx (`sudo nginx -t && sudo systemctl reload nginx`) and visit
`https://yourhost/tuner/` — you should see the login screen.

If you'd rather host the tuner on a different domain, set
`VITE_TUNER_API_URL` when building the React app, or set a runtime override:

```html
<script>window.__BEACH_AWARE_TUNER_API__ = 'https://tuner.example.com/api.php';</script>
```

The runtime override goes inside `index.html` before the main JS loads.

---

## 4. How the React app uses this

On every page load the React bundle does this once, before first render:

1. Calls the API (default `/tuner/api.php`).
2. If the JSON is well-formed, merges its biases into `BEACHES[].suitability`.
3. Caches the JSON in `localStorage` for 5 minutes.
4. If the network call fails or times out (1.2s budget), it renders with the
   built-in defaults — the app never breaks if the tuner is down.

That means **any change you make in the admin is visible to users within ~5
minutes** of their next visit (or instantly on hard refresh).

---

## 5. What the admin lets you edit

For each of 16 beaches × 8 activities:

- **Bias** (-50…+100). 0 is neutral. Positive = worse. The UI hints `-30…+70`
  is the typical useful range.
- **Reasons** — free text, one per line. Shown to users as a "Local knowledge"
  factor when bias ≠ 0.
- **Prohibited?** — checkbox. Forces a red rating regardless of physics
  (e.g. "kitesurfing banned at St Brelade's").
- **Prohibited reason** — short note shown to users when prohibited.

Every save is logged in `bias_audit` with old → new values and a timestamp.

---

## 6. Security notes

- Login is a single shared password, hashed with bcrypt. Sessions are stored
  server-side in `admin_sessions` and identified by a 64-hex random ID.
- Cookie name is `__Host-tuner_sid` in production (requires HTTPS, Path=/,
  HttpOnly, SameSite=Lax). Falls back to `tuner_sid` if `PRODUCTION=0` so
  plain-HTTP dev works.
- Every form submit carries a CSRF token (HMAC of the session ID with
  `SESSION_SECRET`). Tampering with it returns a 400.
- `api.php` is intentionally **public and read-only**. It returns JSON with
  a 5-minute `Cache-Control` and supports CORS allow-listing.

If you ever leak your `.env`, rotate **both** `ADMIN_PASSWORD_HASH` and
`SESSION_SECRET`, then `TRUNCATE admin_sessions;` to log everyone out.

---

## 7. Quick local test (dev)

```bash
# 1. Spin up MariaDB locally and create a DB
sudo service mariadb start
sudo mysql -e "CREATE DATABASE beach_aware; \
               CREATE USER 'beach'@'localhost' IDENTIFIED BY 'beachpass'; \
               GRANT ALL ON beach_aware.* TO 'beach'@'localhost';"

# 2. Apply schema + seeds
mysql -u beach -pbeachpass beach_aware < sql/schema.sql

# 3. Configure .env (PRODUCTION=0, point at the DB above, generate hash+secret)

# 4. Serve it
php -S 127.0.0.1:8088 router.php

# Open http://127.0.0.1:8088/tuner/login.php
```
