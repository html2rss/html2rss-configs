![html2rss logo](https://github.com/html2rss/html2rss/raw/master/support/logo.png)

# html2rss-configs

This repository contains `html2rss` feed configurations for many websites.

## Dynamic Parameters

Configs must include a `parameters` section to define default values for dynamic parameters:

```yaml
parameters:
  query:
    type: string
    default: "technology"
  category:
    type: string
    default: "news"

channel:
  url: https://example.com/search?q=%<query>s&cat=%<category>s
  # ... rest of config
```

The `type` field specifies the parameter type (currently only `string` is supported), and `default` provides the default value when no parameter is explicitly provided.

## Testing

Uses **dynamic test generation** - no individual spec files needed!

```bash
# Test all configs
bundle exec rspec spec/html2rss/configs_dynamic_spec.rb

# Test specific config
make test-config CONFIG=github.com/releases.yml

# Test domain
make test-domain DOMAIN=github.com
```

**Adding new configs**: Just create the YAML file and run tests. No spec file needed.

## Documentation

- [Main Documentation](https://html2rss.github.io/html2rss-configs/)
- [Contributing Guide](https://html2rss.github.io/get-involved/contributing)
- [Sponsorship Page](https://html2rss.github.io/get-involved/sponsoring)
