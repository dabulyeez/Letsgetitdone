# Letsgetitdone
## Login Watch (who is signing in to your accounts)

- `monitor/ip-watch.html`: open it in a browser, paste sign-in activity from Gmail, Shopify, your bank and so on, and every IP shows up on a map. Green is yours, red isn't. It also copies a report you can attach to a police or FTC report, and lists the steps to sign every other device out.
- `bin/ipcheck`: the same check from the terminal.
  - `bin/ipcheck` shows your IP right now
  - `bin/ipcheck --trust 1.2.3.4` saves an IP as yours
  - `bin/ipcheck 73.12.44.201` looks up an IP
  - `pbpaste | bin/ipcheck` (Mac) checks everything you copied
