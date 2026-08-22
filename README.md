![html2rss logo](https://github.com/html2rss/html2rss/raw/master/support/logo.png)

# html2rss-configs

Curated feed YAML for the [html2rss](https://html2rss.github.io) Feed Directory. Configs live under `configs/`; releases ship as signed `registry.v1` bundles.

## Quick links

| Resource | Link |
| --- | --- |
| **Feed Directory** | [Browse pre-built feeds](https://html2rss.github.io/feed-directory) |
| **Contributing** | [AGENTS.md](AGENTS.md) and [catalog reference](.agents/skills/html2rss-config/reference/catalog.md) |
| **Documentation** | [html2rss.github.io](https://html2rss.github.io) |

## Verify locally

```bash
make ready          # lint, validate all configs, run tests
make registry-build # build unsigned bundle to dist/
```

Single-file validation uses the core CLI from the sibling `html2rss` checkout:

```bash
html2rss validate configs/github.com/releases.yml
html2rss feed configs/github.com/releases.yml
```

## Layout

```
configs/   # feed YAML (each file declares registry.id)
tool/      # validate, registry-build
test/      # dynamic config specs + registry bundle spec
```

Release tags trigger CI to sign and publish `registry-bundle.tar.gz`. Running `html2rss-web` instances sync that artifact (or mount a local bundle via `path:` in `config/registries.yml`).
