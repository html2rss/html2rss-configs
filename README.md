![html2rss logo](https://github.com/html2rss/html2rss/raw/master/support/logo.png)

# html2rss-configs

This repository contains `html2rss` feed configurations for many websites.

## 🌐 Community & Resources

| Resource                              | Description                                                 | Link                                                               |
| ------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------ |
| **📚 Documentation & Feed Directory** | Complete guides, tutorials, and browse 100+ pre-built feeds | [html2rss.github.io](https://html2rss.github.io)                   |
| **💬 Community Discussions**          | Get help, share ideas, and connect with other users         | [GitHub Discussions](https://github.com/orgs/html2rss/discussions) |
| **📋 Project Board**                  | Track development progress and upcoming features            | [View Project Board](https://github.com/orgs/html2rss/projects)    |
| **💖 Support Development**            | Help fund ongoing development and maintenance               | [Sponsor on GitHub](https://github.com/sponsors/gildesmarais)      |

**Quick Start Options:**

- **Need a specific feed?** → Browse the [feed directory](https://html2rss.github.io/feed-directory)
- **Want to create feeds?** → Use the [web application](https://html2rss.github.io/web-application)
- **Ruby Developer?** → Check out the [Ruby gem documentation](https://html2rss.github.io/ruby-gem)
- **Want to contribute?** → See our [contributing guide](https://html2rss.github.io/get-involved/contributing)

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
