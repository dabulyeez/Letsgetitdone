---
name: show-monitor
description: Opens Donya's Daily Monitor board and reads out everything on it in one go. Use whenever she says "show monitor", "open monitor", "monitor", or asks to see her board, tasks, bills, progress, or stocks at a glance.
---

# Show monitor

The Daily Monitor is one private claude.ai page that holds everything: https://claude.ai/artifact/5sZWRVGSCjRBkgAgLsUFgt

It already replaces needing several pages open — email, calendar, Shopify, a stock app. When Donya says "show monitor", pull every collection and give her the full picture in one reply, so she never has to go find it herself.

1. Open the board for her: Artifact tool, `action: "open"`, the `url` above. Print the link too so she can tap it.
2. Load ArtifactData via ToolSearch ("select:ArtifactData") and read every collection: `tasks`, `money`, `positions`, `market/today` (a single doc), `agents`, and the latest few `log` entries (`list` with a small limit, newest first if possible, or just read them and sort by `ts`).
3. Give her one complete status, in this order, each as 1-3 short lines — no headers needed, just talk through it plainly:
   - **Right now**: the first open task in the `now` group. If none, say the day's list is clear.
   - **Money**: any `money` doc with `risk: true` and `status: "open"` first (bills overdue, stop-loss alerts), then anything else open.
   - **Stocks**: total gain/loss across `positions` if prices are filled in, and name any position at or near its stop.
   - **Markets**: the one-line summary from `market/today`, if present.
   - **Today and this week**: how many tasks are done out of the total, and name anything still open and due soon.
   - **Agents**: say if any agent's `lastResult` flagged something she hasn't heard yet; otherwise just "agents are running on schedule."
4. If she tells you something got done (she paid a bill, finished a task, unlocked ID.me), update that doc's `status` right then via ArtifactData, pinned with the `version` you read, and add one `log` entry.

Board data layout:
- `tasks/<id>`: `title`, `note`, `owner`, `group` (now | week | agents), `status` (todo | doing | done | blocked), `order`, optional `due`.
- `money/<id>`: `title`, `kind`, `amount`, `due`, `risk` (bool), `status` (open | done), `note`.
- `positions/<id>`: `ticker`, `shares`, `buy`, `stop`, `lastPrice`, `lastUpdated`.
- `market/today`: `asOf`, `source`, `oneLine`, `worthKnowing`, `indexes[]`, `watchlist[]`.
- `agents/<id>`: `name`, `role`, `status` (ready | working | ran), `statusLabel`, `lastRun`, `lastResult`.
- `log/<id>`: `ts`, `who`, `text`.

Never put passwords, verification codes, claim numbers, or account numbers on the board.
