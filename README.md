![html2rss logo](https://github.com/gildesmarais/html2rss/raw/master/support/logo.png)

# html2rss-configs

✌️This repository contains [`html2rss`](https://github.com/gildesmarais/html2rss) _feed configs_ for many websites.  
👉Find all _feed configs_ in the [`configs/` directory](https://github.com/html2rss/html2rss-configs/tree/master/lib/html2rss/configs).  
☝️A handy usage method is via [`html2rss-web`](https://github.com/gildesmarais/html2rss-web).  
💪 Contributions are more than welcome!
[Fork this repository](https://help.github.com/en/github/getting-started-with-github/fork-a-repo),
add your _feed config_ and
[create a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).

## Adding a new feed config

There's a generator for that! 🆒

1. `make config domain=domainname.tld name=whatever`  
   Change `domain` and `name` values to desired values.
2. Head to the generated files and add the selectors and options.  
   [`html2rss`'s README](https://github.com/gildesmarais/html2rss/blob/master/README.md)
   explains how to build a _feed config_.
   Or browse [the existing ones](https://github.com/html2rss/html2rss-configs/tree/master/lib/html2rss/configs) for inspiration.
3. Fetch the feed, run:  
   `bin/fetch domainname.tld/whatever`  
   And with dynamic parameters:  
   `bin/fetch domainname.tld/whatever id=42 foo="bar baz"`

### Dynamic parameters in `channel` attributes

Sometimes there are structurally equal pages with different URLs. In such a case you can add _variables_ to the channel's attributes.

In your _feed config_:

```yml
channel:
  url: "http://domainname.tld/whatever/%{id}.html"
```

See the _more complex formatting_ of the [`sprintf` method](https://ruby-doc.org/core/Kernel.html#method-i-sprintf) for formatting options.

You have to provide the parameters to the spec, too:

```ruby
include_examples 'config.yml', 'domainname.tld/whatever.yml', id: 42
```

Programmatic usage:

```ruby
config = Html2rss::Configs.find_by_name('domainname.tld/whatever', { id: 42 })
```

## Usage

Add to your Gemfile:

```ruby
gem 'html2rss-configs', git: 'https://github.com/html2rss/html2rss-configs.git'
```

Use it in your code:

```ruby
require 'html2rss/configs'

config = Html2rss::Configs.find_by_name('domainname.tld/whatever')
```

This will return the _feed config_.

## Usage with `html2rss-web`

If you're running [`html2rss-web`](https://github.com/gildesmarais/html2rss-web),
you have nothing more to do! 🎉

## Building on the CI

Modifying existing or adding new _feed configs_ will trigger the CI to fetch the feed
and check for the presence of feed items.

See [.travis.yml -> script](https://github.com/html2rss/html2rss-configs/blob/master/.travis.yml) which commands execute during build.
