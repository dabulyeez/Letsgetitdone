---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
---

Deploy $ARGUMENTS to production:

1. Run the test suite
2. Build the application
3. Push to the deployment target
4. Verify the deployment succeeded

## What each step means in this repo

There is no server or build pipeline. "Production" is the published claude.ai Artifact pages and the `main` branch. If `$ARGUMENTS` is empty, ask which page to deploy: `monitor`, `login-globe`, or `all`.

1. **Test.** For the Daily Monitor, run `node .claude/skills/run-letsgetitdone/driver.mjs --smoke` from the repo root. It must pass every check. For any other page, open it in headless Chromium at desktop and phone width (see the `run` skill) and check for console errors and sideways scrolling.
2. **Build.** Nothing to compile. Pages are single HTML files. Confirm the file you will publish is committed and `git status` is clean.
3. **Push.** Republish each page to its existing URL with the Artifact tool, never as a new artifact:
   - `monitor/daily-monitor.html` goes to the URL in `bin/monitor`
   - `monitor/login-globe.html` goes to https://claude.ai/artifact/1CdhDJmmhiPRjpTmuzWWm6

   Then push the branch and make sure its pull request is merged into `main`. Merging is Donya's call, so ask before merging.
4. **Verify.** Read the published page back with the Artifact tool's `read` action and confirm it is the new version. For a page with a database, read one collection back with ArtifactData. Report the link and what you checked.
