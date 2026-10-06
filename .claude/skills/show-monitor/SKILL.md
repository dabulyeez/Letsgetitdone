---
name: show-monitor
description: Opens Donya's Daily Monitor board. Use whenever she says "show monitor", "open monitor", "monitor", or asks to see her board, tasks, progress, or stocks at a glance.
---

# Show monitor

The Daily Monitor is a private claude.ai page: https://claude.ai/artifact/5sZWRVGSCjRBkgAgLsUFgt

When Donya says "show monitor":

1. Open it for her with the Artifact tool: `action: "open"`, `url` set to the link above. Also print the link in your reply so she can tap it.
2. Read the board's `tasks` collection with the ArtifactData tool (`action: "list"`) and give a two-line status: how many tasks are done out of the total, and the one "Right now" item (the first open task in the `now` group).
3. If anything changed since the board was last updated (a task she says she finished, an agent that just ran), update that task's `status` (`todo`, `doing`, `done`, `blocked`) and add one entry to the `log` collection (`ts` as ISO time, `who`, `text`). Pin each write with the `version` you read.

Board data layout: `tasks/<id>` (`title`, `note`, `owner`, `group` = now | week | agents, `status`, `order`, optional `due`), `agents/<id>` (`name`, `role`, `status` = ready | working | ran, `statusLabel`, `lastRun`, `lastResult`), `log/<id>` (`ts`, `who`, `text`), and `market/today` (`asOf`, `source`, `oneLine`, `worthKnowing`, `indexes[]`, `watchlist[]`, each row with `name`, `close`, `change`, `dayHigh`, `dayLow`, `wkHigh`, `wkLow`).

Never put passwords, verification codes, claim numbers, or account numbers on the board.
