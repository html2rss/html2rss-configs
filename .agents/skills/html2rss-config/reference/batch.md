# Batch pipeline

N=1 and N>1. Gate: [AGENTS.md](../../../../AGENTS.md). Wall-time: [pitfalls.md](pitfalls.md).

**Automated batch:** [new.md](new.md) `add_config --file candidates.tsv`.

## Phase 0 — recon

```bash
.agents/skills/html2rss-config/scripts/batch_recon \
  --cache-dir tmp/html2rss-recon --file candidates.tsv
```

Ledger: `tmp/html2rss-recon/ledger.tsv` + cached `.html` per slug. Dry run: `--dry-run`.

| Verdict | Meaning                                       |
| ------- | --------------------------------------------- |
| `BUILD` | No native feed; HTML cached for selectors     |
| `DEFER` | Native RSS/Atom on surface                    |
| `DROP`  | Unreachable, HTTP error, HTTPS→HTTP downgrade |

## Phase 1 — selectors

```bash
.agents/skills/html2rss-config/scripts/analyze_html \
  --from-ledger tmp/html2rss-recon/ledger.tsv
```

Write YAML for `BUILD` rows only. YAML shape: [new.md](new.md).

## Phase 2 — verify

Parallel `check_config`; one rspec boot per fetch lane — AGENTS.md § Quality Gate step 6.

## Repair campaigns

Broken configs: [repair.md](repair.md) diagnose loop, then same verify gate.
