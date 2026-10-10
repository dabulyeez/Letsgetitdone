---
name: review
description: Runs Donya's case reviewer on a letter, dispute, call sheet or email draft and fixes it in place before he sends it. Use when he types /review (optionally with a file or topic, like "/review credit letters" or "/review AT&T"), or says "check this", "is this ready".
---

# /review

1. Work out which files he means. With no argument, review everything he is about to send: the files named in open "now" tasks on the board, plus `case-notes/dispute-letters/`, `case-notes/cfpb-complaints/*DRAFT*`, and `case-notes/child-support/`. With a topic ("credit", "AT&T", "Navy Federal", "child support"), pick the matching files in `case-notes/`.
2. Launch the `case-reviewer-agent` subagent (Agent tool, `subagent_type: "case-reviewer-agent"`) with the file paths. For many files, split them across two or three reviewer agents in one turn.
3. Show Donya each file's verdict line (READY TO SEND or NOT READY: N things left), what was fixed, and the yes/no questions only he can answer. Nothing else.
4. If a reviewed file has a PDF copy in the vault, rebuild and re-upload that PDF only after he confirms the answers.
