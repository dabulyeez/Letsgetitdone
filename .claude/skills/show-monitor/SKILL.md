---
name: show-monitor
description: Opens Donya's Daily Monitor board and reads out everything on it in one go. Use whenever he says "show monitor", "open monitor", "monitor", or asks to see his board, tasks, bills, progress, or stocks at a glance.
---

Board writes follow `.claude/AGENT_RULES.md` (rules 8-11).

# Show monitor

The Daily Monitor is his private claude.ai page that holds everything. One link, for both the page he looks at and the board the agents write to (it holds `tasks`, `money`, `positions`, `market`, `agents`, `log`): https://claude.ai/artifact/LamtUS6ZKmsBJntZ1agBTs

It already replaces needing several pages open — email, calendar, Shopify, a stock app. When Donya says "show monitor", pull every collection and give him the full picture in one reply, so he never has to go find it himself.

1. Open the board for him: print the link above so he can tap it.
2. Load the board tools via ToolSearch ("select:mcp__claude-artifacts__db_get,mcp__claude-artifacts__db_list,mcp__claude-artifacts__db_query,mcp__claude-artifacts__db_write") and read every collection with the board's slug `9e94d782-5efb-40b1-ac72-c2a16f01d326` (the tools take the slug, not the link). Read: `tasks`, `money`, `positions` (`db_list`), `market/today` (a single doc, `db_get`), `agents`, and the latest few `log` entries (`db_query` with `orderBy: "-ts"` and a small `limit`, or just read them and sort by `ts`).
3. Give him one complete status, in this order, each as 1-3 short lines — no headers needed, just talk through it plainly:
   - **Right now**: the first open task in the `now` group. If none, say the day's list is clear.
   - **Money**: any `money` doc with `risk: true` and `status: "open"` first (bills overdue, stop-loss alerts), then anything else open.
   - **Stocks**: total gain/loss across `positions` if prices are filled in, and name any position at or near its stop.
   - **Markets**: the one-line summary from `market/today`, if present.
   - **Today and this week**: how many tasks are done out of the total, and name anything still open and due soon.
   - **Agents**: say if any agent's `lastResult` flagged something he hasn't heard yet; otherwise just "agents are running on schedule."
4. If he tells you something got done (he paid a bill, finished a task, unlocked ID.me), update that doc's `status` right then with `db_write` (`op: "update"`), pinned with `ifVersion` = the `version` you read, and add one `log` entry (a new doc, so no `ifVersion`). One `db_write` call at a time.

Board data layout:
- `tasks/<id>`: `title`, `note`, `owner`, `group` (now | week | agents), `status` (todo | doing | done | blocked), `order`, optional `due`.
- `money/<id>`: `title`, `kind`, `amount`, `due`, `risk` (bool), `status` (open | done), `note`.
- `positions/<id>`: `ticker`, `shares`, `buy`, `stop`, `lastPrice`, `lastUpdated`.
- `market/today`: `asOf`, `source`, `oneLine`, `worthKnowing`, `indexes[]`, `watchlist[]`.
- `agents/<id>`: `name`, `role`, `status` (ready | working | ran), `statusLabel`, `lastRun`, `lastResult`.
- `log/<id>`: `ts`, `who`, `text`.

Never put passwords, verification codes, claim numbers, or account numbers on the board.
