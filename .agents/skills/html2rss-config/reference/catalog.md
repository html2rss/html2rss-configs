# Catalog metadata (Feed Directory)

Every YAML in this repo is a catalog entry. Embedded serialization is owned by `Html2rss::Configs::Catalog` — consumers call `Catalog.entries`; do not re-walk YAML in other repos.

## Required fields

| Field | Rule |
| --- | --- |
| `directory.topics` | 1–2 values from controlled vocabulary — [topics.md](topics.md) |
| `directory.title` | Human label: `{Organization} — {Feed surface}` (em dash) |
| `channel.title` | Same string as `directory.title` (RSS and OPML) |
| `channel.url` | Canonical list URL (may use parameters) |
| `channel.language` | Set when the surface language is clear |

## Optional

| Field | Rule |
| --- | --- |
| `directory.summary` | One sentence, max 160 characters — browse subtitle and search text |

## Parameterized configs

Describe feed intent in `directory.title`, not the template URL.

- Good: `BBC Sounds — Programme episodes`
- Bad: `bbc.co.uk/programmes/%<id>s/episodes/player`

## Title examples

| Config path | `directory.title` |
| --- | --- |
| `anthropic.com/news.yml` | Anthropic — News |
| `who.int/news.yml` | World Health Organization — News |
| `apnews.com/hub.yml` | AP News — Top stories |

## Verification

```bash
bundle exec rspec spec/lib/html2rss/configs/catalog_spec.rb
make validate
```

`Catalog.build_entry` raises `MissingDirectoryTitle` when `directory.title` is absent.

## Downstream consumers

| Consumer | How it reads catalog data |
| --- | --- |
| `html2rss-web` | `GET /api/v1/configs` merges `Catalog.entries` with local `feeds.yml` entries that include `directory.title` |
| Feed Directory (docs site) | Fetches catalog JSON from a running `html2rss-web` instance |

Do not duplicate catalog expansion logic outside `Html2rss::Configs::Catalog`.
