---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
---

Follow `.claude/AGENT_RULES.md`: get Donya's yes before publishing or merging anything.

Deploy $ARGUMENTS to production:

1. Run the test suite
2. Build the application
3. Push to the deployment target
4. Verify the deployment succeeded

## What each step means in this repo

There is no server or build pipeline. "Production" is the published claude.ai Artifact pages and the `main` branch. If `$ARGUMENTS` is empty, ask which page to deploy: `monitor`, `login-globe`, or `all`.

1. **Test.** For the Daily Monitor, run `node .claude/skills/run-letsgetitdone/driver.mjs --smoke` from the repo root. It must pass every check. For any other page, open it in headless Chromium at desktop and phone width (see the `run` skill) and check for console errors and sideways scrolling.
2. **Build.** Nothing to compile. Pages are single HTML files. Confirm the file you will publish is committed and `git status` is clean.
3. **Push.** Republish each page to its existing URL with `mcp__claude-artifacts__publish_files` (or `publish_version` / `edit_version`), passing its slug and `base_version` from `mcp__claude-artifacts__get_artifact` on that URL, never as a new artifact:
   - `monitor/daily-monitor.html` goes to the URL in `bin/monitor` (slug `9e94d782-5efb-40b1-ac72-c2a16f01d326`)
   - `monitor/login-globe.html` goes to https://claude.ai/artifact/1CdhDJmmhiPRjpTmuzWWm6

   Then push the branch and make sure its pull request is merged into `main`. Merging is Donya's call, so ask before merging.
4. **Verify.** Read the published page back with `mcp__claude-artifacts__read_artifact` and confirm it is the new version. For a page with a database, read one collection back with `mcp__claude-artifacts__db_list` (the board's slug is `9e94d782-5efb-40b1-ac72-c2a16f01d326`). Report the link and what you checked.
