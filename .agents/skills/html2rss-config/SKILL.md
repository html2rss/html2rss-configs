---
name: html2rss-config
description: >-
  Create or repair curated html2rss YAML configs in this repo. Router only —
  quality gate and defaults live in AGENTS.md; mode deltas in reference/.
---

# html2rss-config

One config quality loop at a time (multi-config PR only when the user asks).

| Doc                                              | Role                                                 |
| ------------------------------------------------ | ---------------------------------------------------- |
| [`AGENTS.md`](../../../AGENTS.md)                | Quality gate, surface/selector defaults, MCP summary |
| [curation-verbs.md](reference/curation-verbs.md) | CLI/MCP verb table + stale-catalog fix               |
| [pitfalls.md](reference/pitfalls.md)             | Invariants (batch campaigns or quality issues only)  |

## Modes

| Mode     | When                                               | Reference                        |
| -------- | -------------------------------------------------- | -------------------------------- |
| `new`    | Add YAML under `lib/html2rss/configs/<domain>/`    | [new.md](reference/new.md)       |
| `repair` | Zero items, fetch fail, noisy feed                 | [repair.md](reference/repair.md) |
| `expand` | Batch-add across topics                            | [batch.md](reference/batch.md)   |

## Before any write

Follow [`AGENTS.md`](../../../AGENTS.md) defaults. Then: canonical URL (`curl -I -L`), [catalog](reference/catalog.md) metadata (includes topics), `scripts/probe_rss` on the **exact** `channel.url` (exit `3` → defer/drop).

## Tools

MCP/CLI verbs → [curation-verbs.md](reference/curation-verbs.md) (journeys, envelope, catalog-mismatch fix). Quality gate → AGENTS.md.

**MCP broken but CLI works?** Treat as stale Cursor tool catalog, not bad selectors — use `html2rss inspect|recon|capture|test|apply|scrape` or scripts below until the catalog shows bare verb names.

## Scripts

Run from repo root:

| Script                                               | Purpose                                                      |
| ---------------------------------------------------- | ------------------------------------------------------------ |
| [`add_config`](scripts/add_config)                   | Automated create (single URL or `--file`)                    |
| [`batch_recon`](scripts/batch_recon)                 | Parallel recon → BUILD/DEFER/DROP ledger                     |
| [`analyze_html`](scripts/analyze_html)               | Selector hints from cached HTML / ledger                     |
| [`probe_rss`](scripts/probe_rss)                     | Native RSS via `recon` (exit `3` = found)                    |
| [`check_config`](scripts/check_config)               | CLI `validate` + `test`; optional `--fetch` / `--botasaurus` |
| [`register_botasaurus`](scripts/register_botasaurus) | Register Botasaurus-backed configs for fetch specs           |

Gem facades (`recon`, `capture`, `test`, `apply`): [`scripts/html2rss_api.rb`](scripts/html2rss_api.rb).

## Handoff

Mode, files changed, accepted vs dropped/deferred, strategy, commands run, residual risks. No commit/PR unless asked.
