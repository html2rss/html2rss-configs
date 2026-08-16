# Mode: new

Add one curated config. SSOT details: [AGENTS.md](../../../../AGENTS.md).

## Steps

1. Confirm no useful first-party RSS for this surface (else drop/defer).
2. Pick the cleanest list URL (newsroom / archive / category — not marketing homepage).
3. Capture items via skill tool order (MCP → CLI → Botasaurus → Chrome).
4. Write YAML under `lib/html2rss/configs/<registrable-domain>/<name>.yml`.
5. Run AGENTS.md Quality Gate; register Botasaurus path if needed.
6. Handoff per skill.

## YAML skeleton

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/html2rss/html2rss/refs/heads/master/schema/html2rss-config.schema.json
directory:
  topics:
    - tech
channel:
  url: https://example.com/news/
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
- Set `channel.language` when clear (`en` / `de` / `es` / …).
- Add `strategy: botasaurus` + request wait selectors only when Faraday cannot produce items.
- Parameterized URLs need a `parameters:` block with `type: string` and `default`.
- Prefer item-local selectors; anchor on article URL path fragments when possible.

## Ship bar

Live `feed` shows repeated real articles, no nav/footer leakage, absolute URLs. Then repo `make validate` + `make test` + focused fetch.
