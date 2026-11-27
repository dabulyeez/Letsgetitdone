# Running Claude Code on your MacBook
**Donya | Preferred Living LLC**

---

## PART 1 — FIX THE LOGIN (you're stuck here right now)

Your screen says:

> *"That doesn't look like the full code. Copy all of it, including the # in the middle."*

**That message is telling you exactly what's wrong.** The code you paste back has a `#` in the middle, like:

```
aBcD1234efGH#xYz9876wVuT
```

When you double-click it, your Mac only selects the part **before** the `#`. So you paste half a code, and it fails.

### Do this

1. In the terminal, press **`c`** — that copies the long sign-in URL.
2. Open Safari or Chrome. Paste the URL. Press Enter.
3. Sign in with **preferredlivingllc** (the account shown at the top of your terminal).
4. The page gives you a code. **Do not double-click it.**
5. **Click just before the first character, hold the mouse down, drag all the way past the last character, let go.** Or press **⌘A** if the code is alone in a box.
6. **⌘C** to copy.
7. Click back on the Terminal window. **⌘V** to paste. Press Enter.

### How to know you got the whole thing

Before pressing Enter, look at what you pasted. **You should see a `#` somewhere in the middle.** No `#` means you only grabbed half.

### If it still fails

Press **Esc** to cancel, type **`/login`** again, and start over. The code expires after a few minutes, so a slow attempt can fail even when you copy it right.

---

## PART 2 — STARTING UP EACH DAY

Open **Terminal** (⌘Space, type "Terminal", Enter). Then:

```
cd ~/Letsgetitdone
claude
```

That's it. Two lines, every time.

> If `cd ~/Letsgetitdone` says "No such file or directory", the folder is somewhere else. Run `cd ~ && ls` to see your folders and find the right name.

**To leave:** type `/exit` or press Ctrl+C twice.

---

## PART 3 — YOUR COMMANDS

Type these with the slash. They are set up in this repo and they work only from inside this folder.

| Type this | What it does |
|---|---|
| **`/today`** | Your commands for today — who to call, what to mail, what to say, what to attach. Runs Mission Control over your board, your case files and new email. |
| **`/show-monitor`** | Opens your Daily Monitor board and reads out everything on it — tasks, bills, progress, stocks. |
| **`/review`** | Runs your case reviewer over a letter, dispute, call sheet or email draft and fixes it in place. Add a topic: `/review credit letters` |
| **`/run-letsgetitdone`** | Runs the Daily Monitor page locally so a change can be checked or screenshotted. |

**Plain English works too.** You don't have to use slashes. "What do I do today", "show me my board", "check this letter" all do the same thing.

---

## PART 4 — YOUR AGENTS

Six helpers. You don't launch them by hand — Claude calls the right one. This is so you know who does what.

| Agent | What it handles |
|---|---|
| **mission-control-agent** | Runs everything. Turns the board, case files and email into one ordered list of commands for today. |
| **case-reviewer-agent** | Checks every letter, dispute, call sheet and email draft before it goes out. Catches wrong facts, blanks, bad contacts, missed deadlines, private numbers that shouldn't be there. |
| **benefits-case-agent** | PA state benefits, RESEA, ID.me, IRS notices, benefits deadlines. |
| **daily-ops-agent** | Your 24-hour day plan and your Shopify store. |
| **market-watch-agent** | Your stocks and watchlist, in plain language. |
| **wins-and-ideas-agent** | Daily wins, energy and mood, and new ideas for income. |
| **login-watch-agent** | Who is signing in to your accounts: maps each sign-in on the Login Globe and asks "was this you?" |

---

## PART 5 — THE HOUSE RULES (already in place)

These are written into `.claude/AGENT_RULES.md` and every agent follows them. You don't have to do anything — this is just so you know what they will and won't do.

**They will never:**
- Send, reply to or forward an email — only save a draft, after you say yes
- Pay, trade, move money, or change an account
- Sign anything, submit a form, or log in as you
- Ask for or store your Social Security number, passwords, PINs or codes
- Commit or publish anything in `case-notes/` — that folder stays private, always
- Call their own draft "ready" — it goes to the reviewer first
- Invent a fact, a date or a number — they leave `[CONFIRM: ...]` instead

**That last one matters.** If you see `[CONFIRM: ...]` in a document, that's a blank waiting on you — not a mistake.

---

## PART 6 — WHERE YOUR THINGS ARE

```
~/Letsgetitdone/
├── case-notes/              ← your private case files. NEVER goes to GitHub.
│   ├── THE_SIMPLE_VERSION.md
│   ├── DEMAND_PACKAGE_EMAIL.md
│   ├── BEATING_THE_SHARED_ACCESS_DEFENSE.md
│   ├── CASE_FILE.html       ← open this one in a browser
│   ├── HOW_IT_HAPPENED.md
│   ├── MASTER_INDEX_AND_PLAN.md
│   └── ... (11 files total)
├── monitor/
│   └── daily-monitor.html   ← your board
└── .claude/
    ├── AGENT_RULES.md       ← the house rules
    ├── agents/              ← your seven helpers
    └── skills/              ← your slash commands
```

**To open your case file in a browser:**
```
open ~/Letsgetitdone/case-notes/CASE_FILE.html
```

---

## PART 7 — WHEN SOMETHING GOES WRONG

| Problem | Fix |
|---|---|
| "Login expired" | Type `/login`. Follow Part 1. Remember the `#`. |
| Slash commands missing | You're in the wrong folder. `cd ~/Letsgetitdone` then `claude`. |
| Gmail/Calendar not working | Those connect through claude.ai connector settings in your browser, not the terminal. |
| It's asking permission constantly | Type `/permissions` to see what's allowed. |
| Want a different model | Type `/model`. |
| Stuck mid-answer | Press **Esc** to stop it. |
| Need help | Type `/help`. |

---

## PART 8 — THE ONE RULE FOR YOU

**Nothing goes out without you sending it.**

Claude drafts, checks, organises and reminds. **You** click send, you sign, you mail, you file. That's on purpose — it's your name on everything, so it's your hand on the button.

When something's ready, you'll be told exactly where the file is and what to do with it.

---

*Guide written Nov 19, 2026. Lives at `~/Letsgetitdone/LAPTOP_GUIDE.md`.*
