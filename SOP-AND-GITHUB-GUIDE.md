# Beach Aware — Simple SOP & GitHub guide

**Word version:** see `Beach-Aware-SOP-and-GitHub-Guide.docx` in the repository root for a longer, structured copy (tables, page breaks). Regenerate it after changing this Markdown by running:

```bash
python3 scripts/generate_sop_docx.py
```

This document is for anyone working on the Beach Aware project. The language is kept as plain as possible.

**SOP** = *Standard Operating Procedure* = “the usual way we do things.”

---

## Part 1 — What this project is (30 seconds)

1. **Visitors** open the static website (`index.html` + files in `assets/`).
2. The page loads a **small JSON file** from the PHP tuner (`api.php`) to get the latest beach/activity tuning.
3. **Staff** log into the PHP tuner to change those tuning values in a database.

If the API is down, the site still runs using values built into the front-end (so the app does not “go blank”).

---

## Part 2 — Daily rules (do these every time)

### Before you change anything

1. Make sure you are in the project folder on your computer:
   - `BeachAwareProject` (or wherever you cloned the repo).
2. Pull the latest code so you are not working on old files:
   ```bash
   git pull origin main
   ```

### Files you should almost never commit

- **`php-tuner/.env`** — Contains real database and session secrets. It is listed in `.gitignore`. If you paste secrets into GitHub by mistake, treat it as an emergency: rotate passwords and keys.

### After you finish a logical piece of work

1. Save your files.
2. See what changed:
   ```bash
   git status
   ```
3. Commit with a short, honest message (what you did):
   ```bash
   git add .
   git commit -m "Short description of the change"
   ```
4. Push to GitHub:
   ```bash
   git push origin main
   ```

*If your team prefers feature branches (see Part 4), push your branch instead of `main`.*

---

## Part 3 — Where things live (so you edit the right place)

| I want to… | Where to look |
|------------|----------------|
| Change wording or layout on the **public site** | Usually you change the **React source project** (not always in this repo), rebuild, then replace `index.html` and `assets/` here — or follow your team’s deploy notes. |
| Change **API URL** the static site uses | `index.html` — the line that sets `window.__BEACH_AWARE_TUNER_API__`. |
| Change **tuning rules** in the database | Use the **PHP tuner admin** in the browser after deployment, or adjust seed data in `php-tuner/sql/schema.sql` only if you know what you are doing. |
| Change **PHP app behaviour** | `php-tuner/public/*.php`, `php-tuner/src/bootstrap.php`, etc. See `php-tuner/README.md`. |

When unsure, ask before editing `schema.sql` or anything that affects live data.

---

## Part 4 — GitHub in very simple terms

### Words you will see

- **Repository (repo)** — The project on GitHub. Ours: `emmanuel-devstar/beach-aware-project`.
- **Clone** — Download the repo to your computer (once).
- **Commit** — A saved snapshot of your changes on your machine.
- **Push** — Send your commits to GitHub.
- **Pull** — Download other people’s commits from GitHub to your machine.
- **Branch** — A separate line of work (optional). The main one is usually called **`main`**.

### One-time: get the project on your machine

You need Git installed and SSH access to GitHub (your Devstars machine should already be set up).

```bash
cd ~/Documents   # or wherever you keep code
git clone git@github.com:emmanuel-devstar/beach-aware-project.git
cd beach-aware-project
```

### Every day: update, work, save, upload

```bash
cd /path/to/beach-aware-project
git pull origin main
# … edit files …
git status
git add .
git commit -m "Describe your change"
git push origin main
```

### If Git says there is a conflict

That means someone else changed the same lines. Do **not** force-push unless your team lead says so.

1. `git pull origin main` again.
2. Open the files Git lists and look for conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
3. Edit until the file reads correctly, remove the markers, save.
4. `git add` those files, then `git commit`, then `git push`.

Ask for help the first time — conflicts are normal.

### Optional: work on a small branch (cleaner history)

```bash
git pull origin main
git checkout -b my-small-fix
# … edit, then …
git add .
git commit -m "Fix: describe it"
git push -u origin my-small-fix
```

Then on GitHub you can open a **Pull Request** from `my-small-fix` into `main` so someone can review before merge.

---

## Part 5 — How GitHub ties together with this project

1. **Source of truth** — The `main` branch on GitHub should match what you consider the current official version (minus secrets: `.env` stays local).
2. **Deploy** — Your host (server, static file host, etc.) usually pulls from GitHub *or* you upload a build. Follow your team’s hosting checklist; this repo holds both static front-end files and `php-tuner`.
3. **API path** — After deploy, `index.html` must point `window.__BEACH_AWARE_TUNER_API__` at the real `api.php` URL on that host (see `php-tuner/README.md` for Nginx examples).

---

## Part 6 — If something goes wrong

| Problem | First step |
|---------|------------|
| Push rejected | Run `git pull origin main`, fix conflicts if any, push again. |
| Wrong file committed | Tell your lead; reverting is possible. Do not share `.env` in chat. |
| Site works but tuning not updating | Check API URL in `index.html`, server PHP logs, and database connection in `.env` on the server. |

For deep setup (MySQL, bcrypt, Nginx), use **`php-tuner/README.md`**.

---

## Quick command cheat sheet

```bash
git status                  # What changed?
git diff                    # See line-by-line changes
git pull origin main        # Get latest from GitHub
git add .                   # Stage all changes in this folder
git commit -m "Message"    # Save a snapshot locally
git push origin main        # Upload commits to GitHub
git log --oneline -5       # Last 5 commits
```

---

*Document version: matches repo layout as of Beach Aware (Devstars Jersey). Update this file if your team changes branch naming or deploy flow.*
