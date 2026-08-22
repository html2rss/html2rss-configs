# Mode: new

Add one curated config. SSOT details: [AGENTS.md](../../../../AGENTS.md).

## Steps

1. Pick the cleanest list URL (newsroom / archive / category — not marketing homepage). Confirm with `curl -I -L` (canonical host; no HTTPS→HTTP downgrade unless you plan Botasaurus).
2. Confirm no useful first-party RSS **for that exact URL** (else drop/defer). Use `scripts/probe_rss`. Exit `3` = feed found.
3. Capture items via skill tool order (MCP → CLI → Botasaurus → Chrome). If `auto` is empty, still inspect HTML before assuming JS-only — see [pitfalls.md](pitfalls.md).
4. Write YAML under `lib/html2rss/configs/<registrable-domain>/<name>.yml`.
5. Run `scripts/check_config …` (and `--fetch` / `--botasaurus` as needed); verify real `<item>` rows, not only the summary. `scripts/register_botasaurus` if Botasaurus-backed.
6. Handoff per skill.

## YAML skeleton

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/html2rss/html2rss/refs/heads/master/schema/html2rss-config.schema.json
directory:
  topics:
    - tech
  title: Example — News
  summary: Short browse-card description (optional, max 160 characters).
channel:
  url: https://example.com/news/
  title: Example — News
  language: en
  time_zone: UTC
  ttl: 360
selectors:
  items:
    selector: "ARTICLE_CARD_OR_ANCHOR"
    enhance: false
  title:
    selector: "TITLE_WITHIN_ITEM"
  url:
    selector: "a"
    extractor: href
```

Notes:

- Always include `directory.topics` (1–2) — see [topics.md](topics.md).
- Set `directory.title` and mirror it in `channel.title` for catalog and RSS output.
- Set `channel.language` when clear (`en` / `de` / `es` / …). Prefer a real region `time_zone` when obvious (`Africa/Johannesburg`, `Africa/Cairo`, …).
- Add `strategy: botasaurus` only when Faraday cannot produce items (or Faraday is blocked by scheme/redirect). Keep `wait_timeout_seconds` **≤ 30** (work budget; total scrape timeout defaults to 45s).
- Parameterized URLs need a `parameters:` block with `type: string` and `default`.
- Prefer item-local selectors; anchor on article URL path fragments when possible.

## Ship bar

Live `feed` shows repeated real articles, no nav/footer leakage, absolute URLs. Then repo `make validate` + `make test` + focused fetch.

## Footnotes

See [pitfalls.md](pitfalls.md) for full campaign traps. Short list:

- **Folder name:** registrable domain only — avoid `www.` folders unless the host is uniquely `www`.
- **Archive size:** if the list HTML embeds a full multi-year archive, prefer `/latest` or paginated; note blast radius in handoff.
- **Paywall:** titles OK while bodies gated are shippable; mention risk in handoff.
- **MCP:** errored discovery or missing Botasaurus env → skip MCP, use CLI immediately.
- **Batch PR:** allowed when the user asks; still one probe→feed→fetch loop per config.
