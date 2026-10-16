# Daily Monitor for iPhone

A native SwiftUI version of the Daily Monitor board: Tasks (with a "Right now" card), Money and Stocks.
iOS 16 or newer. No third-party packages.

## Open it on your iPhone (needs a Mac with Xcode)
1. In Xcode: File > New > Project > iOS > App. Name it `DailyMonitor`, Interface: SwiftUI, Language: Swift.
2. Delete the `ContentView.swift` and `DailyMonitorApp.swift` Xcode created.
3. Drag every `.swift` file from this folder into the project (tick "Copy items if needed").
4. Plug in your iPhone, pick it as the run target, press Run. The first time, trust your developer account in
   Settings > General > VPN & Device Management.

## What it does
- Everything is stored on the phone in one file. It does NOT sync with the claude.ai board.
- Stocks: stop / near-stop / target chips use the same rules as the web board (near = within 5% above the stop).
  You type prices in yourself. The app does not trade and does not place stop orders.
- Never put account numbers, claim numbers or passwords in notes.

## Not tested yet
Written without Xcode available, so it has not been compiled or run. Expect to fix a typo or two on first build.
