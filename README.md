# html2rss-configs

This repository contains [html2rss](https://github.com/gildesmarais/html2rss) configs for many websites. Find all provided configs in the [`configs/` directory](https://github.com/gildesmarais/html2rss-configs/tree/master/lib/html2rss/configs).

A handy method to use these configs is via [html2rss-web](https://github.com/gildesmarais/html2rss-web).

## Usage via html2rss-web

If you're running [html2rss-web](https://github.com/gildesmarais/html2rss-web),
you have nothing more to do! 🎉

## Usage without html2rss-web

Add to your Gemfile:

```
gem 'html2rss-configs', git: 'https://github.com/gildesmarais/html2rss-configs.git'
```

Use it in your code:

```ruby
require 'html2rss/configs'

config = Html2rss::Configs.find_by_name('domainname.tld/whatever')
```

This will return the feed config.

## Contributions

Contributions are more than welcome!
[Fork this repository](https://help.github.com/en/github/getting-started-with-github/fork-a-repo),
add your config and
[create a Pull Request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).

### Adding a new config

There's a generator for that! 🆒

1. `make config domain=domainname.tld name=whatever`  
   Change `domain` and `name` values to desired values.
2. Head to the generated files and add the selectors and options.  
   [`html2rss`'s README](https://github.com/gildesmarais/html2rss/blob/master/README.md)
   explains how to build a config.
   Or browse the existing configs for inspiration.

3. Fetch the feed, run:  
   `bin/fetch domainname.tld/whatever`
   And with dynamic parameters:
   `bin/fetch domainname.tld/whatever id=42 foo="bar baz"`

### Dynamic parameters in `channel` attributes

Sometimes there are structurally equal pages with different URLs. In such a case you can add _variables_ to the channel's `url`, `title` and `language` attributes.

In your config YAML:

```yaml
channel:
  title: "domainname.tld: whatever %<id>s"
  url: "http://domainname.tld/whatever/%<id>s.html"
```

See the _more complex formatting_ of the [`sprintf` method](https://ruby-doc.org/core-2.6.3/Kernel.html#method-i-sprintf) for more complex formatting options.

You have to provide the parameters to the spec, too:

```ruby
include_examples 'config.yml', 'domainname.tld/whatever.yml', id: 42
```

Programmatic usage:

```ruby
config = Html2rss::Configs.find_by_name('domainname.tld/whatever', { id: 42 })
```

## Building on the CI

Modifying existing or adding new configs will trigger the CI to fetch the feed
and check for the presence of feed items.

See [.travis.yml -> script](https://github.com/gildesmarais/html2rss-configs/blob/master/.travis.yml) which commands execute during build.
