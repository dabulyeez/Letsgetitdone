---
name: run-letsgetitdone
description: Run, start, test, build or screenshot Donya's Daily Monitor page (monitor/daily-monitor.html) locally. Use when asked to run the monitor, check a change to it, take a screenshot of the board, test the stocks table or the add-task and tick flows, or check it on a phone-width screen.
---

This repo is Donya's personal assistant setup: Claude agents and skills in `.claude/`, plus one real app, `monitor/daily-monitor.html`. That page is a claude.ai Artifact. In production it reads and writes a shared database through `window.claude.use("db")`, which only exists inside claude.ai, so it cannot be opened as a plain file. The driver `.claude/skills/run-letsgetitdone/driver.mjs` loads the page in headless Chromium with an in-memory stand-in for that database. It can seed data, click, fill, screenshot and dump the stub database.

All paths are relative to the repo root, and **run the driver from the repo root**: `--page`, `--out` and any `seed <file>` argument resolve against the current directory, so from anywhere else the page file is not found.

## Prerequisites

Nothing to install in the cloud container. It already has Node 22, Playwright 1.56 (installed globally) and Chromium under `/opt/pw-browsers`. The driver finds Playwright through `npm root -g`. `chromium-cli` is not installed here, which is why the driver exists. There is no build step and there are no dependencies to install.

## Run (agent path)

Smoke check. It runs 19 checks (empty states, stock stop and target chips, ticking a task, adding a task, no clipped columns at 400px, no console errors), saves three screenshots, and exits non-zero if anything fails (1 for a failed check or a startup crash, 2 if the checks themselves crash):

```bash
node .claude/skills/run-letsgetitdone/driver.mjs --smoke
```

Screenshots land in `/tmp/letsgetitdone-shots/` (`--out <dir>` changes it): `smoke-1-empty.png`, `smoke-2-seeded-desktop.png`, `smoke-3-seeded-phone-dark.png`. Look at them. The checks cannot judge layout.

The smoke checks are tied to `sample-seed.json` (they look for `near $90.00`, `hit $33.00`, `hit $65.00`, "not set in app" and a money item titled `DEMOA near stop`) and to the page's element ids (`#now-lead`, `#positions`, `#money`, `#tasks`, `#new-task`, `#add-task` and others). If you edit the seed, or run `--smoke --page <other file>`, expect failures that are not regressions.

Interactive REPL, one command per line on stdin:

```bash
node .claude/skills/run-letsgetitdone/driver.mjs --out /tmp/shots <<'EOF'
seed .claude/skills/run-letsgetitdone/sample-seed.json
text #now-lead
viewport phone
theme dark
ss phone-dark
click "#money .tick"
fill #new-task "Call PA UC about RESEA"
select #new-group week
click "#add-task button[type=submit]"
dump
errors
quit
EOF
```

| command | what it does |
|---|---|
| `seed [file]` | Write docs into the stub db. Format is `{collection: {docId: {...}}}`. Defaults to `sample-seed.json`. |
| `ss [name]` | Full-page screenshot to `<out>/<name>.png`, prints the path. With no name it writes `shot.png`, overwriting the last one. |
| `viewport desktop\|phone\|WxH` | Desktop is 1280x900, phone is 400x860. |
| `theme light\|dark` | Sets the emulated color scheme. |
| `click <sel>`, `fill <sel> <text>`, `select <sel> <value>` | Playwright actions. Quote selectors or text that contain spaces. |
| `text <sel>`, `wait <sel>`, `eval <js>` | Read inner text, wait for an element, evaluate JS in the page. |
| `dump` | Print the whole stub database as JSON: seeded docs and the page's writes together. Docs the page adds have ids `auto1`, `auto2`, and so on, and edits to seeded docs show as changed fields. Use it to prove a click saved. |
| `errors` | Console and page errors so far, or `(none)`. |
| `quit` | End the session. A blank line or a line starting with `#` is ignored, and end of input also ends it. |

How the REPL behaves: only double quotes group words (there is no escaping), `fill` and `eval` rejoin their arguments with single spaces, and `click`, `fill` and `text` act on the first match. A command that fails prints `ERROR: <first line>` after a 5 second timeout and the session continues, so a typo does not hang it. The process still exits 0. Seeding again overwrites any doc you already ticked or edited, so start a new run for a clean state. `eval` runs in the page, so use single quotes or backticks inside it.

Point `--page <path>` at another HTML file to test a different version of the page.

To check a change, run the smoke check, then use the REPL to reproduce what you changed, screenshot at both `desktop` and `phone`, and read the screenshots. Donya mostly uses this on a phone.

`sample-seed.json` is fake data. The tickers are `DEMOA`, `DEMOB` and `DEMOC`, set up so one position is near its stop, one is past it, and one is at its target. Its due dates are absolute (Oct 5 to Oct 20, 2026), so the "late" and "today" chips change as the real date moves on. Never write that file to the real board.

## Run (human path)

```bash
bin/monitor   # opens the real board in a browser; headless it only prints the link
```

Inside the cloud container it prints `Open this link: https://claude.ai/artifact/...` and exits. The board's URL is in `bin/monitor` (`bin/start` opens it plus the old Stock Watch page and calls `curl ifconfig.me`, so it needs network). The real board's data lives in claude.ai. Read and write it with the Artifact and ArtifactData tools, not with the driver. To ship a page change, republish `monitor/daily-monitor.html` with the Artifact tool to that same URL.

## Test

The repo has no test suite. The smoke check above is the test. It passes 19 of 19 on a clean checkout.

## Gotchas

- **The driver serves the page from `http://monitor.test/` through a route, not with `page.setContent`.** `setContent` does not re-run init scripts, so `window.claude` never gets installed and the board says "Sign in to claude.ai to load your board." Never switch it back.
- **Google Fonts are stubbed out with empty responses.** The container cannot reach them, so screenshots use system fallback fonts instead of Bricolage Grotesque, Atkinson Hyperlegible and JetBrains Mono (numbers and chips use the system monospace). Spacing and wrapping can differ a little from the real page. Nothing is filtered from `errors`, so anything listed there is real.
- **The smoke check's "no horizontal page scroll" test cannot see clipped content.** Tables sit in `overflow-x: auto` boxes, so a table can lose its Stop and Target columns and the page still reports no overflow. A real bug like that shipped once. The check "Gain, Stop and Target cells are fully visible at 400px" covers columns 5 to 7, so update its `td:nth-child(n+5)` selector if you reorder columns. Add a similar explicit check when you add columns.
- **The stub is simpler than the real database.** It has no access rules, no `version` or `if_version` pinning, no latency and no persistence. It supports only `collection`/`doc` with `get`, `set`, `update`, `delete`, `add` and `onSnapshot`: no `where`, `orderBy`, `limit` or batches, and the `onSnapshot` error callback never fires, so the page's "Lost connection to the board" path cannot be exercised. `use()` returns null for every capability except `db`. It proves rendering and write calls, not what the real artifact database accepts. After a change that adds fields or collections, check one real write with the ArtifactData tool.
- **The page is a fragment, not a document.** `<title>`, `<link>`, `<style>` and `<script>` all sit at the top level of the file because the Artifact tool wraps them in a skeleton at publish time. The driver recreates that skeleton. Do not add `<html>` or `<body>` to the file.
- **Playwright is only importable by path.** ESM ignores `NODE_PATH`, so a plain `import 'playwright'` from this folder fails. The driver uses `createRequire` on the `npm root -g` directory.

## Troubleshooting

- **`page.waitForFunction: Timeout 10000ms exceeded` at startup**: the page never reached "Live". Either the db stub was not installed (check that the driver still uses `page.route` and `page.goto`, not `setContent`), or the page script threw during its first render, for example after an element id was renamed. Run with `--page` on a known-good copy to tell them apart.
- **`seed` prints `seeded` but the page shows nothing**: the seed collections must be `tasks`, `money`, `positions`, `agents`, `log` and `market/today`, matching what the page subscribes to.
- **A smoke check fails after a CSS change**: open the matching screenshot in `/tmp/letsgetitdone-shots/` before touching the check.
