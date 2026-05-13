# Beach Aware (Devstars Jersey)

**Beach Aware** is a **beta** web app that helps people in Jersey choose safer times and places for beach and sea activities.

It combines weather-style factors (for example wind, tides, currents, and water quality) with **local tuning** so guidance can reflect real-world conditions at each beach.

---

## What you get

- **Public website** — A React app (built to static files) that visitors load in the browser.
- **PHP “tuner”** — A small admin tool plus a read-only **API**. Staff use the admin to adjust **per-beach, per-activity** settings (biases, notes, and prohibited activities). The public site reads those values from the API.

---

## What’s in this repository

| Path | Purpose |
|------|--------|
| `index.html` + `assets/` | The **front-end** users see (pre-built React bundle). |
| `php-tuner/` | **Backend**: login, admin screens, database, and `api.php` (JSON for the app). |
| `public.zip` | Packaged copy of deployable assets (if you use it in your hosting flow). |

**Important:** Database passwords and secrets live in `php-tuner/.env`. That file is **not** stored in Git (see `.gitignore`). Create and fill in `.env` on each machine or server using **`php-tuner/README.md`** (configuration section).

---

## Documentation

- **[SOP and GitHub guide (Word)](./Beach-Aware-SOP-and-GitHub-Guide.docx)** — Detailed, structured procedures plus GitHub usage (open in Microsoft Word, Google Docs, etc.).
- **[SOP and GitHub guide (Markdown)](./SOP-AND-GITHUB-GUIDE.md)** — Same topic in simple web-friendly text; regenerate the Word file with `python3 scripts/generate_sop_docx.py` after edits.
- **[PHP tuner details](./php-tuner/README.md)** — Database setup, Nginx, security, and local testing.

---

## Live context

- Intended public URL pattern (from the app metadata): `https://www.devstars.com/jersey/beach-aware/`
- This is a **Devstars Jersey** project. Treat forecasts and ratings as **guidance**, not a replacement for official safety advice.

---

## GitHub

Remote: `git@github.com:emmanuel-devstar/beach-aware-project.git`  
Default branch: `main`
