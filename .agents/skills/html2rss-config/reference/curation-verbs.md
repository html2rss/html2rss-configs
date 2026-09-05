# Curation verbs (CLI + MCP)

Seven verbs — no `_url` / `_config` suffixes. Upstream: `html2rss/CONTEXT.md` § Frozen contract.

| Verb | Job | CLI / MCP |
| --- | --- | --- |
| inspect | Diagnostics: URL, status, alternates, surface | `inspect` |
| recon | BUILD / DEFER / DROP verdict + native_feed | `recon` |
| capture | YAML draft → test → apply | `capture` |
| validate | Schema only | `validate` |
| test | Schema + live extraction | `test` |
| apply | Ship RSS (zero items = error) | `apply` |
| scrape | Articles now, one-shot | `scrape` |

Batch: `batch_inspect`, `batch_recon`, `batch_scrape`. CLI aliases: `feed` → `apply`, `auto` → `scrape`.

## Three journeys

| Goal | Path |
| --- | --- |
| Articles now | `scrape` (empty items can still be `ok` — follow `guidance`) |
| Durable YAML | `capture` → `test` → `apply` (side door: `validate` → `test` → `apply`) |
| Should we build? | `inspect` → `recon` when alternates or surface warrant it |

**inspect ≠ recon:** inspect is cheap diagnostics; recon adds verdict + native_feed. Follow envelope `next_step` and `guidance` — do not parse scrape text as a raw item array.

## Envelope (every MCP tool)

`ok`, `next_step` (bare verb or `done` / `read_runtime`), `guidance`, `payload`. Resources: `html2rss://schema`, `extractors`, `strategies`, `runtime` (`botasaurus_configured` boolean only).

## Strategy

| Tool | `strategy: auto` behavior |
| --- | --- |
| `scrape`, `capture` | Default (HTTPX) → Botasaurus fallback — **do not** retry explicit `default` after `auto` |
| `inspect` | Default only (cheap); pin `botasaurus` when you need browser rendering |

## Configs-repo note

`capture` → `payload.yaml` is a **draft**. Still add `registry.id`, `directory.topics`, titles, and catalog fields per [catalog.md](catalog.md) before shipping.

## MCP in Cursor

Namespace: `user-html2rss`. Prefer MCP when the catalog matches the server; **CLI is the fallback authority** (`html2rss …` from `../html2rss`).

### Catalog mismatch (common after gem upgrade)

**Symptom:** Cursor lists `inspect_url`, `capture_config`, … but calls return `-32602 Invalid params`; new names like `inspect` are “tool not found”.

**Cause:** MCP server upgraded (bare verbs); **client `tools/list` cache stale**.

**Fix (in order):** Settings → MCP → disable/enable `html2rss` → Reload Window → quit Cursor fully. Confirm catalog shows `inspect`, `capture`, `test`, `apply`, `scrape` (not `*_url` / `*_config`).

**Until fixed:** use CLI or skill scripts (`html2rss_api.rb`) — same verbs, same pipeline.

### Botasaurus

`BOTASAURUS_SCRAPER_URL` must be on the **MCP process** (`mcp.json` env), not only your shell. If `next_step` is `read_runtime` or scrape stays empty, check `html2rss://runtime`.
