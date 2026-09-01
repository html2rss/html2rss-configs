# Mode: new

Add one curated config. Defaults and gate: [AGENTS.md](../../../../AGENTS.md).

## Automated

```bash
.agents/skills/html2rss-config/scripts/add_config 'https://example.com/news/' --topics tech,news
```

Probes via `recon`, captures YAML via `capture` (draft — add catalog fields). Fallback: manual selectors. Gate: AGENTS.md.

## Manual fallback

When automation fails: tool order per [SKILL.md](../SKILL.md); write YAML under `lib/html2rss/configs/<domain>/`; `scripts/check_config` (+ `--fetch` / `--botasaurus` as needed).

## YAML skeleton

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/html2rss/html2rss/refs/heads/master/schema/html2rss-config.schema.json
directory:
  topics: [tech]
  title: Example — News
channel:
  url: https://example.com/news/
  title: Example — News
  language: en
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

Metadata: [catalog.md](catalog.md). Ship bar: AGENTS.md Quality Gate.
