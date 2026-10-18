# Letsgetitdone
## Login Watch (who is signing in to your accounts)

- `monitor/ip-watch.html`: open it in a browser, paste sign-in activity from Gmail, Shopify, your bank and so on, and every IP shows up on a map. Green is yours, red isn't. It also copies a report you can attach to a police or FTC report, and lists the steps to sign every other device out.
- `monitor/ip-globe.html`: the same check on a 3D night-side globe. Red lines run from you to every sign-in that isn't yours, and tapping one flies the globe there. It also shows the IP and location every website sees for you, and how to hide it with a VPN. It shares your saved IPs and last results with the flat map.
- `monitor/login-globe.html`: the published Login Globe (https://claude.ai/artifact/1CdhDJmmhiPRjpTmuzWWm6). It opens on any phone. Claude loads sign-ins from your email security alerts into it, and you tap "This was me" or "Not me" on each one. To republish it, publish this file to that same URL with the Artifact tool.
- `bin/ipcheck`: the same check from the terminal.
  - `bin/ipcheck` shows your IP right now
  - `bin/ipcheck --trust 1.2.3.4` saves an IP as yours
  - `bin/ipcheck 73.12.44.201` looks up an IP
  - `pbpaste | bin/ipcheck` (Mac) checks everything you copied

## Live Watch (your own price watcher)

`monitor/live-watch.html`, also at https://dabulyeez.github.io/Letsgetitdone/monitor/live-watch.html once merged.

- Crypto prices are live, tick by tick, from Coinbase. No key needed.
- Stock prices are live from Finnhub after you paste a free key from finnhub.io in the settings panel.
- Type your entry, stop and target on any card. The card shows how far you are from each, the reward-to-risk ratio, and warns when a "signal" entry is far from the real price.
- Alerts (on-page, sound, and notifications when added to the Home Screen) fire at your stop, your target, and within 3% of your stop.
- Watches only. It never buys or sells. Your symbols, plans and key stay in your own browser, not in this public repo.
