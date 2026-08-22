# Catalog metadata (Feed Directory)

Every YAML in this repo is a catalog entry. Declare feed identity explicitly — do not rely on filesystem path.

## Feed identity (`registry.id`)

```yaml
registry:
  id: europa.eu/europarl/press-room
  aliases: []   # optional; previous ids after a rename
directory:
  title: "European Parliament — Press room"
  topics: [civic]
```

| Field | Rule |
| --- | --- |
| `registry.id` | Unique within the bundle; slug `org/surface[/variant]`; lowercase; `[a-z0-9._/-]`; no `www.` prefix |
| `registry.aliases` | Optional previous ids (same bundle); resolved at feed lookup; **not** listed in catalog API |

Pick a sensible path under `configs/` (group by organization). Path is contributor ergonomics only.

**Rename workflow:** change `registry.id`; add the old id to `aliases`; remove the alias in a later release when comfortable.

## Required fields

| Field              | Rule                                                           |
| ------------------ | -------------------------------------------------------------- |
| `registry.id`      | Explicit feed identity (see above)                             |
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
| `configs/who.int/news.yml`        | Official news and statements from the World Health Organization.      |
| `configs/apple/newsroom.yml`  | Product announcements and press releases from Apple.                  |
| `configs/github.com/releases.yml` | Release notes for a GitHub repository (owner and name as parameters). |

## Parameterized configs

Describe feed intent in `directory.title`, not the template URL.

- Good: `BBC Sounds — Programme episodes`
- Bad: `bbc.co.uk/programmes/%<id>s/episodes/player`

## Title examples

| Config path              | `directory.title`                |
| ------------------------ | -------------------------------- |
| `configs/anthropic.com/news.yml` | Anthropic — News                 |
| `configs/who.int/news.yml`       | World Health Organization — News |
| `configs/apnews.com/hub.yml`     | AP News — Top stories            |

## Verification

```bash
bundle exec rspec test/registry.spec.rb
make validate
make registry-build
```

`make registry-build` emits a signed `registry.v1` bundle; `Html2rss::Registry::CatalogBuilder.build_entry` raises `MissingDirectoryTitle` when `directory.title` is absent.

## Downstream pipeline

| Layer | Owner | Responsibility |
| --- | --- | --- |
| YAML + bundle | `html2rss-configs/` | `configs/`; `tool/registry-build` → signed tarball on release |
| Catalog rows | `html2rss/` | `Html2rss::Registry::CatalogBuilder` from verified bundle manifest |
| Sync + API | `html2rss-web/` | `config/registries.yml`, `Registry::Sync`, `Registry::Index`, `GET /api/v1/configs` |
| Browse UI | `html2rss.github.io/` | Fetches catalog JSON from a running instance |

Wire rows add `source: registry` and `registry: <registry_id>` in the web handler. Do not duplicate catalog expansion outside `CatalogBuilder`.
