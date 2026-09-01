# html2rss-configs Agent Guide

This repo owns the curated YAML config set for `html2rss`.

Primary goal: add or repair configs that are stable, shippable, and easy to verify. Prefer a narrow, clean surface over a broad noisy one.

## Scope

- Source of truth here: `lib/html2rss/configs/`.
- Do not hand-edit generated schema output.
- Keep config work separate from downstream docs, web, or example changes unless the task explicitly includes them.

## Defaults

- Use the registrable domain folder, not a subdomain folder, unless there is a strong existing reason.
- Start from the cleanest article list the site offers, not the marketing homepage by default.
- Prefer stable list/detail extraction over extracting every possible field.
- If the site only becomes reliable on a narrower path, use that narrower path.
- Omit brittle fields. If dates or descriptions are low quality, leave them out.
- Set `enhance: false` when enhancement pulls in page chrome, duplicate cards, or unrelated links.
- Require top-level `directory.topics` (non-empty) using the controlled vocabulary from
  `Html2rss::Config::Validator::DIRECTORY_TOPICS` (`sports`, `energy`, `tech`, `science`,
  `news`, `entertainment`, `jobs`, `finance`, `security`, `travel`, `environment`,
  `consumer`, `civic`, `product`, `research`). Prefer 1–2 primary topics.
- Require `directory.title` for catalog listing; mirror the same value in `channel.title` for RSS output.
- Optional `directory.summary` (max 160 characters) for feed-directory browse cards.
- Prefer setting `channel.language` (`en`/`de`/`es`/`en-GB`/`de-DE`) when the surface language is clear.

## Feed Directory catalog

- **Serialization owner:** `Html2rss::Configs::Catalog` in `lib/html2rss/configs/catalog.rb` builds wire-ready entries from packaged YAML. Do not duplicate YAML walking in `html2rss-web` or the docs site.
- **Entry type:** `Html2rss::Configs::CatalogEntry` (`Data.define`) — use `#to_h` for the v1 wire shape (`id`, `path`, `source`, `directory`, `channel`, `parameters`).
- **Agent reference:** [.agents/skills/html2rss-config/reference/catalog.md](.agents/skills/html2rss-config/reference/catalog.md).

## Surface Selection

Prefer these surfaces first:

- dedicated newsroom or blog archive pages
- category pages with one repeated card structure
- stable subpaths like `/blog/latest` or `/blog/everything/`

Avoid these unless they are the only workable option:

- homepages with hero content mixed with promos
- pages that combine multiple unrelated card systems
- infinite-scroll surfaces unless Botasaurus is already clearly required
- localized or geo-redirecting entry pages when a stable non-localized path exists

## Selector Strategy

Start with the smallest useful selector set:

- `items`
- `title`
- `url`

Add fields only when they are clean:

- `description`
- `published_at`
- `author`
- `categories`

Useful patterns:

- Prefer the repeated article card itself as `items`, especially when it is a single anchor.
- Anchor on article URLs or stable path fragments instead of generic headings.
- Keep selectors item-local when possible.
- Do not add complexity to recover weak optional fields.

## html2rss MCP

Prefer `user-html2rss` when the tool catalog shows **bare verbs** (`inspect`, `capture`, …). Same words as CLI and [curation-verbs.md](.agents/skills/html2rss-config/reference/curation-verbs.md).

**Journeys:** scrape (now) · capture → test → apply (YAML) · inspect → recon (build?). Follow each result’s `next_step` / `guidance`; `capture` YAML is a draft until catalog fields are added.

**Setup:** `BOTASAURUS_SCRAPER_URL` on the MCP process (`mcp.json`), not only your shell. Read `html2rss://runtime` when `next_step` is `read_runtime`.

**After gem upgrade:** If old names (`inspect_url`, `capture_config`) still appear in Cursor or calls return `-32602`, the server may be fine — **reload MCP / Cursor** until the catalog matches. Until then, use CLI (`html2rss …` from `../html2rss`) or skill scripts — authoritative fallback.

**Strategy:** `scrape`/`capture` + `auto` run Faraday → Botasaurus (don’t retry `faraday` after `auto`). `inspect` + `auto` uses Faraday only; pin `botasaurus` for JS-heavy inspect.

## Chrome MCP

Use Chrome MCP when the static HTML is unclear, the page is hydrated, or Faraday fetch returns zero items while the browser shows a valid list.

Recommended sequence:

1. Open the target URL.
2. Take an accessibility snapshot.
3. Identify the exact repeated item boundary.
4. Confirm the title and URL live inside that boundary.
5. Record the final URL if the page redirects by locale or renders a different surface than expected.

If Chrome MCP is unavailable (`Transport closed` or page-lock errors), do this recovery sequence:

1. Kill stale Chrome MCP processes (`pkill -9 -f 'chrome-devtools-mcp|Chrome for Testing'`).
2. Retry Chrome MCP once before continuing.
3. If still unavailable, continue with `curl -I -L`, `html2rss apply`, and HTML inspection in a temporary file.
4. Explicitly report Chrome MCP outage in the final handoff.

## Botasaurus

Use Botasaurus when:

- the page is JS-rendered
- Faraday fetch returns zero items but Chrome shows a valid repeated list
- the site is bot-sensitive enough that static fetch is unreliable

Local Botasaurus notes:

- Botasaurus fetch tests require `BOTASAURUS_SCRAPER_URL` (typically `http://localhost:4010`)

Do not default the whole repo to Botasaurus. Use it only for configs that need it.

## Command Assumptions

Assume the `html2rss` CLI is available on `PATH` when working against the sibling core repo.

- Use `html2rss ...` in examples and one-off validation commands.
- If the CLI is not installed globally in the current environment, run the equivalent command from the sibling `html2rss/` checkout, typically `bundle exec exe/html2rss ...`.
- In this repo, keep using `make ...` and `bundle exec rspec ...` because those are the implemented entrypoints.

## Fast Path

1. Find the cleanest stable candidate URL.
2. Inspect the DOM in Chrome MCP before writing selectors.
3. Create the YAML with the schema modeline and minimal selectors.
4. Validate the single file with the core CLI.
5. Generate a live feed with `html2rss apply`.
6. Tighten selectors until the feed output is clean.
7. Run repo validation and non-fetch tests.
8. Run the appropriate fetch lane:
   - plain fetch for static or Faraday-backed configs
   - Botasaurus fetch for JS-heavy or Botasaurus-backed configs

## Quality Gate

For every new or changed config, verify in this order.

1. Single-file runtime validation in the core repo:

```bash
cd ../html2rss
html2rss validate /abs/path/to/config.yml
```

2. Single-file live feed generation in the core repo:

```bash
cd ../html2rss
html2rss apply /abs/path/to/config.yml
```

(`feed` is a CLI alias for `apply`.)

3. Catalog serialization for changed configs:

```bash
bundle exec rspec spec/lib/html2rss/configs/catalog_spec.rb
```

4. Repo-wide validation in this repo:

```bash
make validate
```

5. Repo non-fetch tests in this repo:

```bash
make test
```

6. Focused fetch verification:

- Faraday-backed candidate:

```bash
bundle exec rspec --tag fetch --example 'example.com/feed.yml' spec/html2rss/configs_dynamic_spec.rb
```

- Botasaurus-backed candidate:

```bash
BOTASAURUS_SCRAPER_URL=http://localhost:4010 \
bundle exec rspec --tag fetch --example 'example.com/feed.yml' spec/html2rss/configs_dynamic_spec.rb
```

7. If fetch still fails, decide explicitly whether:

- selectors are wrong
- the page needs Botasaurus
- the chosen surface is too noisy or too dynamic
- the candidate should be downgraded or dropped

8. Cross-runtime mismatch check (required when core feed works but fetch specs fail):

- confirm canonical URL with redirect tracing:

```bash
curl -I -L -s https://example.com | sed -n '1,20p'
```

- compare behavior in both runtimes:
  - core repo (`../html2rss`) via `html2rss apply`
  - configs repo fetch lane (`bundle exec rspec --tag fetch --example ...`)
- if selectors are valid in core but fetch lane still returns zero items, treat this as request-strategy/runtime mismatch, not selector success.
- in that case: prefer Botasaurus-backed verification if available; otherwise mark as downgraded/deferred with evidence.

## Runtime Debugging

Use the core CLI as the authority for single-config debugging. The quickest loop is:

1. `validate`
2. `apply`
3. inspect the RSS for zero items, nav/footer leakage, duplicates, relative URLs, or noisy descriptions
4. adjust selectors
5. rerun

If Botasaurus works but Faraday does not, keep the config narrow and classify it as Botasaurus-backed instead of trying to rescue it with brittle tweaks.

Additional high-value checks:

- Always normalize `channel.url` to the final canonical host/path (`www` vs non-`www`, retired legacy paths).
- Prefer selectors anchored to content links (`h3 a`, `a[href*='/article/']`) over container-only selectors.
- Remove optional fields first when quality drops (`categories`, synthetic IDs, weak descriptions) before adding selector complexity.
- Set `enhance: false` early if enhancement starts pulling nav/hero/market widgets.

## Scrape (reconnaissance)

Use `scrape` for reconnaissance, not as proof that a config is ready. CLI alias: `auto`.

```bash
cd ../html2rss
html2rss scrape 'https://example.com'
```

Use it to:

- discover likely repeated item selectors
- compare Faraday and Botasaurus behavior quickly
- decide whether a site belongs in the curated set at all

Do not ship raw scrape output without manual tightening into a curated config.

## Drop Or Downgrade

Drop or defer when:

- the page stays noisy after reasonable selector tightening
- the site already offers first-party RSS and this config adds little curated value
- the page depends on unstable interaction flows that are not worth encoding

Downgrade when:

- a narrower subpath is much cleaner than the flagship page
- the config is acceptable without descriptions or dates
- month-level dates are the best the source offers

## Reporting

When finishing config work, report:

- files changed
- accepted configs
- downgraded configs and why
- dropped or deferred candidates and why
- commands actually run
- residual risks, especially selector drift, localization dependence, or Botasaurus dependence
- whether Chrome MCP was available during validation
- whether focused fetch specs matched core runtime behavior

## Contributor notes

Config workflow router: [.agents/skills/html2rss-config/SKILL.md](.agents/skills/html2rss-config/SKILL.md) (links to mode refs; does not duplicate this gate).

Stale CLI/MCP verb drift check:

```bash
rg -n 'html2rss (feed|auto)\b|capture_config|inspect_url|scrape_url|test_config|apply_config|batch_scrape_urls|batch_inspect_urls' \
  --glob '!**/configs/**' --glob '!lib/html2rss/configs/**' AGENTS.md README.md .agents/ spec/
```

Exclude `bin/validate_configs` (repo script name). Prefer `apply` / `scrape` and bare MCP verb names in docs.
