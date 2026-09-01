# Runtime pitfalls

Invariants for `new` / `repair` / batch campaigns. Quality gate: [AGENTS.md](../../../../AGENTS.md). Pipeline: [batch.md](batch.md).

## Never guess URL paths

- Do **not** invent paths (`/news`, `/press-releases`, …) without a live HTTP 200.
- 404/403/DNS/SSL → drop or find a verified URL; do not commit guessed paths.
- Selectors must yield `items.count >= 1` via `Html2rss.apply` before shipping.

## Semantic feed quality

- Reject feeds where all items share one URL; enforce link diversity.
- Reject generic titles ("Read more", "PDF", …) or titles under 4 characters.
- Resolve topics from `Html2rss::Config::Validator::DIRECTORY_TOPICS` at runtime.

## Probe the exact surface

- Run `probe_rss` / `batch_recon` on the same URL as `channel.url`, not just the homepage.
- Exit `3` / ledger `DEFER` → native RSS found; defer unless curated value is clearly higher.

## Faraday vs JS

- `html2rss scrape` returning 0 items ≠ empty HTML — fetch HTML before declaring Botasaurus-only.
- Prefer nested title selectors (`h6`, `aria-label`) over whole-card text.

## Redirects and schemes

- Faraday rejects HTTPS→HTTP downgrades; confirm with `curl -I -L`.
- If only stable surface downgrades: try Botasaurus once, then drop.

## Botasaurus

- `BOTASAURUS_SCRAPER_URL=http://localhost:4010` on MCP process (`mcp.json`) and shell; health at `/health`.
- **`wait_timeout_seconds` must be ≤ 30** (API validation against the work budget). Values above 30 → HTTP **422**. Do not confuse with the **45s** default total scrape wall (boot + navigate + wait).
- 504 / scrape timeout → remove brittle `wait_for_selector`, retry once, then drop if still unreliable.
- Shipping `strategy: botasaurus` → `scripts/register_botasaurus`.

## MCP / CLI drift

- Cursor catalog stale after gem upgrade: old `*_url` tool names, `-32602` on calls, new `inspect` “not found” — reload MCP/Cursor; use CLI until catalog shows bare verbs ([curation-verbs.md](curation-verbs.md)).
- `scrape` with `auto`: do not retry explicit `faraday` after empty auto (chain already ran).

## Selectors

- Anchor on article URL path fragments; use nested title / `aria-label` over card chrome.
- `enhance: false` on items unless proven necessary.
