---
name: html2rss-config
description: >-
  Create or repair curated html2rss YAML feed configs in this repo (lib/html2rss/configs/),
  including directory.topics, selectors, Faraday vs Botasaurus triage, and the AGENTS.md
  quality gate. Use when adding a new feed config, fixing a broken/zero-item config,
  tightening selectors, or diagnosing fetch failures for a curated config. Do not use for
  html2rss gem core, html2rss-web, docs-only work, or bulk coverage-expansion campaigns.
---

# html2rss-config

Thin workflow skill for **one config at a time**. Quality-gate SSOT: repo root [`AGENTS.md`](../../../AGENTS.md). Do not duplicate that gate here.

## Modes

| Mode     | When                                                     | Reference                                  |
| -------- | -------------------------------------------------------- | ------------------------------------------ |
| `new`    | Add a YAML under `lib/html2rss/configs/<domain>/`        | [reference/new.md](reference/new.md)       |
| `repair` | Fix existing config (zero items, fetch fail, noisy feed) | [reference/repair.md](reference/repair.md) |

Pick mode from the user ask. Grow later with more modes/references; keep this file short.

## Before any write

1. Read [`AGENTS.md`](../../../AGENTS.md) (surface selection, selectors, drop rules).
2. Confirm canonical URL (`curl -I -L`); prefer **registrable-domain** folder.
3. Assign `directory.topics` (1–2) — see [reference/topics.md](reference/topics.md).
4. If a solid first-party RSS already covers the surface and curated value is low → **drop/defer** with evidence (AGENTS.md).

## Tool order

1. **user-html2rss MCP** — `capture_config` / `scrape_url` / `inspect_url` / `validate_config` when discovery works.
2. Else **core CLI** from sibling `../html2rss` — `html2rss validate|feed` (or `bundle exec exe/html2rss …`).
3. **Botasaurus** when Faraday returns zero items: `BOTASAURUS_SCRAPER_URL=http://localhost:4010`.
4. **Chrome MCP** only if Faraday + Botasaurus fail or the item boundary is unclear. Report Chrome outage in handoff if unavailable.

## Fast path (quick)

Soft budget: one tight loop per site (~3–4 minutes of wall effort). Faraday → Botasaurus → Chrome. If still zero/noisy → **stop**, report drop/defer with evidence, unless the user says keep going.

Minimal selectors first: `items`, `title`, `url`. Omit brittle optional fields. Set `enhance: false` when chrome leaks in.

## Done checklist

From AGENTS.md Quality Gate, in order:

1. `html2rss validate /abs/path/to/config.yml`
2. `html2rss feed /abs/path/to/config.yml` — clean items, no nav junk
3. `make validate` (this repo)
4. `make test` (non-fetch)
5. Focused fetch:
   - Faraday: `bundle exec rspec --tag fetch --example 'domain/file.yml' spec/html2rss/configs_dynamic_spec.rb`
   - Botasaurus: same with `BOTASAURUS_SCRAPER_URL=http://localhost:4010`
6. If `strategy: botasaurus` (or fetch only works via Botasaurus): add path to [`spec/support/botasaurus_fetch_configs.rb`](../../../spec/support/botasaurus_fetch_configs.rb) — **required**.

## Handoff

Report: mode, files changed, accepted vs dropped/deferred + why, topics, Faraday vs Botasaurus, Chrome MCP availability, commands + exit honesty, residual risks (selector drift, localization, Botasaurus dependence).

Do not push or open a PR unless the user asks. Commits only when the user asks (global commit rules).
