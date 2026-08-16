# Runtime pitfalls (campaign harvest)

Hard-won notes for `new` / `repair`. Prefer these over rediscovering the same traps.
SSOT for quality gate remains [AGENTS.md](../../../../AGENTS.md).

## Probe the exact surface

- Run `scripts/probe_rss` on the **same URL** you will put in `channel.url`, not only the domain homepage.
- Example: AllAfrica homepage looked RSS-free; `https://allafrica.com/latest/` advertises a working RDF/RSS → **defer**.
- Exit `3` = feed found → drop/defer unless curated value is clearly higher than the native feed.

## Coverage / gap campaigns (when the user asks)

Still **one config quality loop at a time**. A single PR with many configs is fine if the user asked for it — do not skip probe → selectors → `check_config` → focused fetch per file.

Prefer additions that:

- lack usable first-party RSS
- are primary sources (IGO / regulator / think tank / dedicated newsroom list)
- avoid NA/EU-only shortlists when the ask is “global” or names a region (Africa, LATAM, …)

Defer WordPress/national newsrooms that already ship `/feed` or `rel=alternate`.

## Faraday vs “JS site”

- `html2rss auto` returning 0 items ≠ empty HTML. **Fetch and inspect** (`curl -L` + Nokogiri, or Botasaurus `/scrape` HTML) before declaring Botasaurus-only.
- ISS Africa press/ISS Today: Faraday HTML already contained `a.card[href^=…]`; auto failed; explicit selectors shipped on Faraday.
- Prefer nested title selectors (`h6.card-subtitle`, `aria-label`) over whole-card text (dates, bylines, “PRIME”, region chrome).

## Redirects and schemes

- Faraday **rejects HTTPS→HTTP downgrades** (`UnsupportedUrlScheme`). Confirm with `curl -I -L` and watch `Location`.
- If the only stable surface downgrades: try Botasaurus once; if still flaky/timeout → **drop**, do not ship a lottery config (tralac lesson).

## Botasaurus contract

- Health: `GET http://localhost:4010/health` (root `/` is often 404 — that is normal).
- Env: `BOTASAURUS_SCRAPER_URL=http://localhost:4010`.
- **`wait_timeout_seconds` must be ≤ 20** (API validation). Values like 30/45 → HTTP **422**.
- 504 / scrape timeout → remove brittle `wait_for_selector`, retry once, then drop if still unreliable.
- Shipping `strategy: botasaurus` → always `scripts/register_botasaurus domain/file.yml`.

## Reading `check_config` output

- The script may print the **channel title** in the first summary lines. Confirm item quality by inspecting RSS `<item>` rows (or Nokogiri on feed XML), not the summary alone.

## Tool order reminders

- If `user-html2rss` MCP is `error` / discovery failed → **skip immediately** to CLI. Do not burn the timebox.
- Chrome MCP is last resort; curl + Botasaurus HTML + explicit selectors often enough. Report Chrome availability in handoff.

## Selector patterns that worked

| Pattern | Example |
| -------- | ------- |
| Drupal field link | `span.field-content a[href^="/latest-news/"]` (SADC) |
| Card anchor + nested title | `a.card[href^="/iss-today/"]` + `h6.card-subtitle` (ISS) |
| Heading link | `h4.title a[href*="/News/"]` (Ahram); `h4 a[href*="lang2.html"]` (PanaPress) |
| Clean `aria-label` | `a[href*="/tea/news/"][aria-label]` + `extractor: attribute` / `attribute: aria-label` (EastAfrican) |

Always set `enhance: false` on items unless you have proven need.
