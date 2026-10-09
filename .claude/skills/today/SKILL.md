---
name: today
description: Gives Donya his exact commands for today - who to call, what to mail, what to say, what to attach - by running Mission Control over the board, the case files and new email. Use when he types /today or says "what do I do", "give me my commands", "get everything done", or "send everything off".
---

# /today

1. Launch the `mission-control-agent` subagent (Agent tool, `subagent_type: "mission-control-agent"`). Tell it today's date and time and anything Donya just said (what he finished, what he answered), so it starts from the latest state.
2. If its list includes any paper to mail or send, launch `case-reviewer-agent` on those files in the same turn so each one comes back READY or NOT READY with the blanks named.
3. Give Donya the command list exactly as Mission Control wrote it, with the reviewer's READY / NOT READY tag next to each paper. Keep it short. Put the vault link (https://claude.ai/artifact/C8KxgWHJ79DjVeemQ2wayj) and board link (https://claude.ai/artifact/5sZWRVGSCjRBkgAgLsUFgt) at the end.
4. Never send, submit, pay or trade for him. He makes the calls and mails the letters.
