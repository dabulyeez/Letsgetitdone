#!/usr/bin/env node
// Headless driver for monitor/daily-monitor.html.
//
// The real page only works inside claude.ai (it needs the `db` capability), so this driver
// wraps the page in the same skeleton the Artifact tool uses and installs an in-memory
// stand-in for window.claude.use("db") before the page script runs.
//
//   node .claude/skills/run-letsgetitdone/driver.mjs --smoke        # scripted checks, exit 1 on failure
//   node .claude/skills/run-letsgetitdone/driver.mjs <<'EOF'        # REPL: one command per line on stdin
//   seed .claude/skills/run-letsgetitdone/sample-seed.json
//   ss desktop
//   quit
//   EOF
//
// Options: --out <dir> (default /tmp/letsgetitdone-shots), --page <path> (default monitor/daily-monitor.html)
import { createRequire } from 'node:module'
import { execSync } from 'node:child_process'
import { readFileSync, mkdirSync, existsSync } from 'node:fs'
import { createInterface } from 'node:readline'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const here = dirname(fileURLToPath(import.meta.url))
const argv = process.argv.slice(2)
const opt = (name, dflt) => { const i = argv.indexOf(name); return i >= 0 ? argv[i + 1] : dflt }
const OUT = resolve(opt('--out', '/tmp/letsgetitdone-shots'))
const PAGE = resolve(opt('--page', 'monitor/daily-monitor.html'))
const SEED = resolve(here, 'sample-seed.json')
mkdirSync(OUT, { recursive: true })

// playwright is installed globally in this container; ESM ignores NODE_PATH, so resolve it by hand.
const globalRoot = execSync('npm root -g', { encoding: 'utf8' }).trim()
const { chromium } = createRequire(globalRoot + '/')('playwright')

// Same shape the Artifact tool wraps pages in (see the artifact-capabilities skill).
const SKELETON = (body) => `<!doctype html><html><head><meta charset=utf8><meta name=viewport content="width=device-width,initial-scale=1,viewport-fit=cover"><style>:root{color-scheme:light;padding:env(safe-area-inset-top,0px) 0 env(safe-area-inset-bottom,0px)}body{margin:0;font:14px system-ui,sans-serif}img{max-width:100%}[hidden]{display:none!important}</style></head><body>${body}</body></html>`

// In-memory db with the surface of db.d.ts that the page uses: collection/doc, get/set/update/delete/add, onSnapshot.
const DB_STUB = () => {
  const store = {}            // collection -> { id: data }
  const collSubs = {}         // collection -> Set<fn>
  const docSubs = {}          // "coll/id" -> Set<fn>
  let n = 0
  const split = (p) => { const i = p.indexOf('/'); return [p.slice(0, i), p.slice(i + 1)] }
  const docSnap = (c, id) => { const d = store[c]?.[id]; return { id, exists: d !== undefined, data: () => d === undefined ? undefined : structuredClone(d), metadata: { fromCache: false, hasPendingWrites: false } } }
  const collSnap = (c) => { const docs = Object.keys(store[c] || {}).map((id) => docSnap(c, id)); return { docs, size: docs.length, empty: !docs.length, docChanges: () => [], metadata: { fromCache: false, hasPendingWrites: false } } }
  const notify = (c, id) => { (collSubs[c] || []).forEach((f) => f(collSnap(c))); (docSubs[c + '/' + id] || []).forEach((f) => f(docSnap(c, id))) }
  const write = (c, id, data, merge) => { (store[c] ||= {})[id] = merge ? { ...(store[c][id] || {}), ...data } : structuredClone(data); notify(c, id) }
  const docRef = (c, id) => ({
    id, path: c + '/' + id,
    get: async () => docSnap(c, id),
    set: async (d) => write(c, id, d, false),
    update: async (d) => { if (!store[c]?.[id]) throw { code: 'invalid_argument', message: 'no such doc' }; write(c, id, d, true) },
    delete: async () => { delete store[c]?.[id]; notify(c, id) },
    onSnapshot: (next) => { (docSubs[c + '/' + id] ||= new Set()).add(next); queueMicrotask(() => next(docSnap(c, id))); return () => docSubs[c + '/' + id].delete(next) },
  })
  const db = {
    doc: (p) => docRef(...split(p)),
    collection: (c) => ({
      path: c,
      doc: (id = 'auto' + ++n) => docRef(c, id),
      add: async (d) => { const id = 'auto' + ++n; write(c, id, d, false); return docRef(c, id) },
      get: async () => collSnap(c),
      onSnapshot: (next) => { (collSubs[c] ||= new Set()).add(next); queueMicrotask(() => next(collSnap(c))); return () => collSubs[c].delete(next) },
    }),
  }
  window.claude = { use: async (name) => (name === 'db' ? db : null) }
  window.__dump = () => structuredClone(store)
  window.__seed = (obj) => { for (const [c, docs] of Object.entries(obj)) for (const [id, d] of Object.entries(docs)) write(c, id, d, false) }
}

const browser = await launch()
async function launch() {
  try { return await chromium.launch({ args: ['--no-sandbox'] }) }
  catch { return await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }) }
}
const VIEWPORTS = { desktop: { width: 1280, height: 900 }, phone: { width: 400, height: 860 } }
const ctx = await browser.newContext({ viewport: VIEWPORTS.desktop })
const page = await ctx.newPage()
const errors = []
page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()) })
page.on('pageerror', (e) => errors.push('pageerror: ' + e.message))
// Google Fonts are not reachable from the container. Answer with an empty 200 so the fallback stack
// renders and no console error is produced (an aborted request would log net::ERR_FAILED).
await page.route(/fonts\.(googleapis|gstatic)\.com/, (r) => r.fulfill({ status: 200, contentType: r.request().url().includes('googleapis') ? 'text/css' : 'font/woff2', body: '' }))
page.setDefaultTimeout(5000)  // a mistyped selector should fail in 5s, not Playwright's default 30s
await page.addInitScript(DB_STUB)
// goto (not setContent) so the init script above runs before the page script.
await page.route('http://monitor.test/', (r) => r.fulfill({ contentType: 'text/html', body: SKELETON(readFileSync(PAGE, 'utf8')) }))
await page.goto('http://monitor.test/')
await page.waitForFunction(() => document.getElementById('conn')?.textContent === 'Live', null, { timeout: 10000 })

const seed = async (file) => page.evaluate((o) => window.__seed(o), JSON.parse(readFileSync(resolve(file), 'utf8')))
const shot = async (name) => { const p = `${OUT}/${name}.png`; await page.screenshot({ path: p, fullPage: true }); return p }
const dump = () => page.evaluate(() => window.__dump())

// ---- smoke mode ----
async function smoke() {
  const results = []
  const check = (name, ok, extra = '') => { results.push(ok); console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${ok ? '' : '  ' + extra}`) }
  const txt = (sel) => page.locator(sel).first().innerText()

  check('empty board shows the no-tasks message', (await txt('#now-lead')).includes('No tasks yet'), await txt('#now-lead'))
  check('empty board shows the no-positions message', (await txt('#stock-tiles')).includes('No positions yet'))
  await shot('smoke-1-empty')

  await seed(SEED)
  await page.waitForTimeout(100)
  const seeded = await dump()
  const firstNow = Object.values(seeded.tasks).filter((t) => t.group === 'now').sort((a, b) => a.order - b.order)[0]
  check('Right now shows the first open "now" task', (await txt('#now-lead')) === firstNow.title, await txt('#now-lead'))
  check('progress line counts done tasks', /^\d+ of \d+ done$/.test(await txt('#task-progress')), await txt('#task-progress'))
  const stocks = await page.locator('#positions').innerText()
  check('stock near its stop gets a "near" chip', /near \$90\.00/i.test(stocks), stocks)
  check('stock under its stop gets a "hit" chip', /hit \$33\.00/i.test(stocks), stocks)
  check('stock at its target gets a "hit" target chip', /hit \$65\.00/i.test(stocks), stocks)
  check('unset stop order is flagged', /not set in app/i.test(stocks), stocks)
  check('total gain/loss tile is a dollar amount', /^-?\$[\d,]+\.\d\d$/.test(await txt('#stock-tiles .tile:first-child .v')), await txt('#stock-tiles .tile:first-child .v'))
  check('open risky money item is listed first', (await txt('#money li')).includes('DEMOA near stop'), await txt('#money li'))
  check('market summary renders', (await txt('#market-line')).length > 0)
  check('all agents listed', (await page.locator('#agents li').count()) === Object.keys(seeded.agents).length)
  await shot('smoke-2-seeded-desktop')

  await page.locator('#tasks .tick').first().click()
  await page.waitForTimeout(100)
  const after = await dump()
  check('ticking a task writes status "done"', Object.values(after.tasks).some((t) => t.title === firstNow.title && t.status === 'done'))
  check('ticking a task adds a log entry', Object.values(after.log).some((l) => /^Done: /.test(l.text)))

  await page.fill('#new-task', 'Smoke test task')
  await page.selectOption('#new-group', 'week')
  await page.click('#add-task button[type=submit]')
  await page.waitForTimeout(100)
  check('add-task form creates a "week" task', Object.values((await dump()).tasks).some((t) => t.title === 'Smoke test task' && t.group === 'week'))
  check('input clears after adding', (await page.inputValue('#new-task')) === '')

  await page.setViewportSize(VIEWPORTS.phone)
  await page.emulateMedia({ colorScheme: 'dark' })
  await page.waitForTimeout(100)
  const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth)
  check('no horizontal page scroll at 400px', overflow <= 0, `overflow ${overflow}px`)
  const clipped = await page.evaluate(() => [...document.querySelectorAll('#positions tr:not(.head) td:nth-child(n+5)')].filter((td) => td.getBoundingClientRect().right > window.innerWidth).length)
  check('stock Gain, Stop and Target cells are fully visible at 400px', clipped === 0, `${clipped} cells cut off`)
  await shot('smoke-3-seeded-phone-dark')

  check('no console errors', errors.length === 0, errors.join(' | '))
  const failed = results.filter((r) => !r).length
  console.log(`\n${results.length - failed}/${results.length} passed. Screenshots in ${OUT}`)
  return failed ? 1 : 0
}
// ---- REPL mode ----
function tokenize(line) { return [...line.matchAll(/"([^"]*)"|(\S+)/g)].map((m) => m[1] ?? m[2]) }
async function run(cmd, args) {
  switch (cmd) {
    case 'seed': await seed(args[0] || SEED); return 'seeded'
    case 'ss': return await shot(args[0] || 'shot')
    case 'viewport': { const v = VIEWPORTS[args[0]] ?? (() => { const [w, h] = args[0].split('x').map(Number); return { width: w, height: h } })(); await page.setViewportSize(v); return JSON.stringify(v) }
    case 'theme': await page.emulateMedia({ colorScheme: args[0] }); return args[0]
    case 'click': await page.click(args[0]); return 'ok'
    case 'fill': await page.fill(args[0], args.slice(1).join(' ')); return 'ok'
    case 'select': await page.selectOption(args[0], args[1]); return 'ok'
    case 'text': return await page.locator(args[0]).first().innerText()
    case 'wait': await page.waitForSelector(args[0], { timeout: 5000 }); return 'ok'
    case 'eval': return JSON.stringify(await page.evaluate(args.join(' ')))
    case 'dump': return JSON.stringify(await dump(), null, 1)
    case 'errors': return errors.length ? errors.join('\n') : '(none)'
    default: return `unknown command: ${cmd}  (seed ss viewport theme click fill select text wait eval dump errors quit)`
  }
}

if (argv.includes('--smoke')) {
  const code = await smoke().catch((e) => { console.error('smoke crashed:', e.message); return 2 })
  await browser.close(); process.exit(code)
}
for await (const line of createInterface({ input: process.stdin })) {
  const [cmd, ...args] = tokenize(line.trim())
  if (!cmd || cmd.startsWith('#')) continue
  if (cmd === 'quit') break
  try { console.log(`> ${line.trim()}\n${await run(cmd, args)}`) } catch (e) { console.log(`> ${line.trim()}\nERROR: ${e.message?.split('\n')[0]}`) }
}
await browser.close()
