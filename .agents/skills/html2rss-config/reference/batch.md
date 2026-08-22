# Batch pipeline

Default workflow for **N=1** and **N>1**. Pass a one-URL list for a single add — same scripts and phases.

Quality-gate SSOT: [AGENTS.md](../../../../AGENTS.md). Wall-time constraints: [pitfalls.md](pitfalls.md).

## Prerequisites

- Repo root as cwd.
- Sibling `../html2rss` or `html2rss` on `PATH` for validate/feed.
- Optional: `BOTASAURUS_SCRAPER_URL=http://localhost:4010` when Faraday cannot fetch items.
- Ruby with stdlib + Nokogiri (Gemfile / system gem used by this repo).

## Phase 0 — parallel recon

```bash
.agents/skills/html2rss-config/scripts/batch_recon \
  --cache-dir tmp/html2rss-recon \
  'https://example.com/news/'

.agents/skills/html2rss-config/scripts/batch_recon \
  --cache-dir tmp/html2rss-recon \
  --file candidates.tsv
```

`candidates.tsv` lines: `URL`, or `slug\tURL`, or `slug\tregion\tURL` (`#` comments ok).

**Success:** `tmp/html2rss-recon/ledger.tsv` with `BUILD` / `DEFER` / `DROP`, plus one `.html` cache file per slug.

Verdicts:

| Verdict | Meaning                                                                                             |
| ------- | --------------------------------------------------------------------------------------------------- |
| `BUILD` | No verified first-party feed; HTML cached for selectors (may still need Botasaurus if thin/blocked) |
| `DEFER` | Native RSS/Atom verified on the surface                                                             |
| `DROP`  | Unreachable, HTTP error, HTTPS→HTTP downgrade, or error page                                        |

Dry plan (no network): `batch_recon --dry-run --file candidates.tsv`

## Phase 1 — selectors from cache

```bash
.agents/skills/html2rss-config/scripts/analyze_html \
  --from-ledger tmp/html2rss-recon/ledger.tsv
```

Write YAMLs only for `BUILD` rows under `lib/html2rss/configs/<registrable-domain>/`. Use MCP/`check_config` only when cache analysis is insufficient. Botasaurus scrape: thin/empty/blocked HTML only — one retry max (`wait_timeout_seconds` ≤ 30, work budget), then drop.

YAML notes: [new.md](new.md). Topics: [topics.md](topics.md).

## Phase 2 — batched verification

```bash
# offline validate (example: sibling CLI)
html2rss validate lib/html2rss/configs/domain/*.yml

# parallel feed checks (Faraday group)
.agents/skills/html2rss-config/scripts/check_config domain/a.yml &
.agents/skills/html2rss-config/scripts/check_config domain/b.yml &
wait

# one rspec boot per fetch lane
bundle exec rspec --tag fetch \
  --example 'domain/a.yml' \
  --example 'domain/b.yml' \
  spec/html2rss/configs_dynamic_spec.rb
```

## Phase 3 — campaign gate

```bash
make validate
make test
.agents/skills/html2rss-config/scripts/register_botasaurus domain/bot.yml   # if needed
```

## N=1 shortcut

Same pipeline; one URL:

```bash
.agents/skills/html2rss-config/scripts/batch_recon \
  --cache-dir tmp/html2rss-recon \
  'https://example.com/news/'
.agents/skills/html2rss-config/scripts/analyze_html \
  --from-ledger tmp/html2rss-recon/ledger.tsv
# write YAML → check_config → focused fetch → make validate/test when done
```

## Repair campaigns

For broken configs, treat paths as the candidate list: diagnose with `check_config`, then the same Faraday→Botasaurus→drop loop. See [repair.md](repair.md).
