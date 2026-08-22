# Batch wall-time constraints

Present constraints for config campaigns (N≥1). Quality-gate commands stay in [AGENTS.md](../../../../AGENTS.md).

## Recon

- Probe the **exact** intended `channel.url` (not a homepage stand-in).
- Prefer `scripts/batch_recon` over sequential `scripts/probe_rss` loops.
- Cache HTML once per candidate; author selectors from that cache.
- Treat first-party RSS on the surface as **DEFER** (no curated config unless curated value is explicit).
- Use `html2rss auto` only as optional discovery; never as proof a config is ready (AGENTS.md Auto-Source).

## Request strategy

- Faraday first.
- Botasaurus only when Faraday returns zero/blocked items and the browser shows a real list.
- Cap Botasaurus `wait_timeout_seconds` at **≤ 30** (post-boot work budget; total scrape wall defaults to 45s separately).
- One scrape retry on transient Botasaurus errors, then **DROP** with ledger evidence — no retry spirals.

## Authoring

- Soft budget ~3–4 minutes wall effort per BUILD site after recon.
- Minimal selectors first: `items`, `title`, `url`. Drop brittle optionals early.
- Set `enhance: false` when enhancement pulls chrome/nav/hero.

## Verification batching

- Offline: validate all new/changed YAML files in one pass.
- Feed checks: run several `scripts/check_config` jobs in parallel (grouped by strategy).
- Focused fetch: **one rspec boot per lane**, multiple `--example` flags:

```bash
bundle exec rspec --tag fetch \
  --example 'domain/a.yml' \
  --example 'domain/b.yml' \
  spec/html2rss/configs_dynamic_spec.rb
```

Botasaurus lane: same command with `BOTASAURUS_SCRAPER_URL=http://localhost:4010`.

- For campaigns: `make validate` and `make test` **once at the end**, not per config.
- Register every shipped Botasaurus config with `scripts/register_botasaurus`.

---

# Runtime pitfalls (campaign harvest)

Hard-won notes for `new` / `repair`. Prefer these over rediscovering the same traps.
SSOT for quality gate remains [AGENTS.md](../../../../AGENTS.md). Pipeline: [batch.md](batch.md).

## Probe the exact surface

- Run `scripts/probe_rss` / `scripts/batch_recon` on the **same URL** you will put in `channel.url`, not only the domain homepage.
- Example: AllAfrica homepage looked RSS-free; `https://allafrica.com/latest/` advertises a working RDF/RSS → **defer**.
- Exit `3` / ledger `DEFER` = feed found → drop/defer unless curated value is clearly higher than the native feed.

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
- **`wait_timeout_seconds` must be ≤ 30** (API validation against the work budget). Values above 30 → HTTP **422**. Do not confuse with the **45s** default total scrape wall (boot + navigate + wait).
- 504 / scrape timeout → remove brittle `wait_for_selector`, retry once, then drop if still unreliable.
- Shipping `strategy: botasaurus` → always `scripts/register_botasaurus domain/file.yml`.

## Reading `check_config` output

- The script may print the **channel title** in the first summary lines. Confirm item quality by inspecting RSS `<item>` rows (or Nokogiri on feed XML), not the summary alone.

## Tool order reminders

- If `user-html2rss` MCP is `error` / discovery failed → **skip immediately** to CLI. Do not burn the timebox.
- Chrome MCP is last resort; curl + Botasaurus HTML + explicit selectors often enough. Report Chrome availability in handoff.

## Selector patterns that worked

| Pattern                    | Example                                                                                              |
| -------------------------- | ---------------------------------------------------------------------------------------------------- |
| Drupal field link          | `span.field-content a[href^="/latest-news/"]` (SADC)                                                 |
| Card anchor + nested title | `a.card[href^="/iss-today/"]` + `h6.card-subtitle` (ISS)                                             |
| Heading link               | `h4.title a[href*="/News/"]` (Ahram); `h4 a[href*="lang2.html"]` (PanaPress)                         |
| Clean `aria-label`         | `a[href*="/tea/news/"][aria-label]` + `extractor: attribute` / `attribute: aria-label` (EastAfrican) |

Always set `enhance: false` on items unless you have proven need.
