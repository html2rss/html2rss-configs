# Catalog metadata (Feed Directory)

Every YAML in this repo is a catalog entry. Registry bundle serialization is owned by `Html2rss::Registry::CatalogBuilder` in the core `html2rss` gem — build with `make registry-build`; do not re-walk YAML in other repos.

## Required fields

| Field              | Rule                                                           |
| ------------------ | -------------------------------------------------------------- |
| `directory.topics` | 1–2 values from controlled vocabulary — [topics.md](topics.md) |
| `directory.title`  | Human label: `{Organization} — {Feed surface}` (em dash)       |
| `channel.title`    | Same string as `directory.title` (RSS and OPML)                |
| `channel.url`      | Canonical list URL (may use parameters)                        |
| `channel.language` | Set when the surface language is clear                         |

## Optional

| Field               | Rule                                                                                                                                        |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `directory.summary` | One concrete sentence, max 160 characters — browse subtitle and search text. Say what the feed covers; do not write `RSS feed for {title}.` |

### Summary examples

| Config path               | `directory.summary`                                                   |
| ------------------------- | --------------------------------------------------------------------- |
| `who.int/news.yml`        | Official news and statements from the World Health Organization.      |
| `apple.com/newsroom.yml`  | Product announcements and press releases from Apple.                  |
| `github.com/releases.yml` | Release notes for a GitHub repository (owner and name as parameters). |

## Parameterized configs

Describe feed intent in `directory.title`, not the template URL.

- Good: `BBC Sounds — Programme episodes`
- Bad: `bbc.co.uk/programmes/%<id>s/episodes/player`

## Title examples

| Config path              | `directory.title`                |
| ------------------------ | -------------------------------- |
| `anthropic.com/news.yml` | Anthropic — News                 |
| `who.int/news.yml`       | World Health Organization — News |
| `apnews.com/hub.yml`     | AP News — Top stories            |

## Verification

```bash
bundle exec rspec test/registry.spec.rb
make validate
make registry-build
```

`CatalogBuilder.build_entry` raises `MissingDirectoryTitle` when `directory.title` is absent.

## Downstream consumers

| Consumer                   | How it reads catalog data                                                                                    |
| -------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `html2rss-web`             | `GET /api/v1/configs` merges registry bundles with local `feeds.yml` entries that include `directory.title` |
| Feed Directory (docs site) | Fetches catalog JSON from a running `html2rss-web` instance                                                  |

Do not duplicate catalog expansion logic outside `Html2rss::Registry::CatalogBuilder`.
