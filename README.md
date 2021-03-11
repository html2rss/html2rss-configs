![html2rss logo](https://github.com/html2rss/html2rss/raw/master/support/logo.png)

# html2rss-configs

✌️This repository contains [`html2rss`](https://github.com/html2rss/html2rss) _feed configs_ for many websites.  
👉Find all _feed configs_ in the [`configs/` directory](https://github.com/html2rss/html2rss-configs/tree/master/lib/html2rss/configs).  
☝️A handy usage method is via [`html2rss-web`](https://github.com/gildesmarais/html2rss-web).  
💪 Contributions are more than welcome!
[Fork this repository](https://help.github.com/en/github/getting-started-with-github/fork-a-repo),
add your _feed config_ and
[create a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).

## Adding a new feed config

There's a generator for that! 🆒

1. Fork this repo and run `bundle install`.
2. Start the generator by typing: `bin/generator`  
3. Build your feed config and answer 'y' in the last step to create the files.
4. Optionally, edit the created files. Read [`html2rss`'s README](https://github.com/html2rss/html2rss/blob/master/README.md) what is possible or browse [existing configs](https://github.com/html2rss/html2rss-configs/tree/master/lib/html2rss/configs) for inspiration.
4. To test, run:
   `bundle exec html2rss feed lib/html2rss/configs/domainname.tld/whatever`  

## Using dynamic parameters in `channel` attributes

When you're using dynamic parameters, you have to provide the parameters to the spec, too:

```ruby
include_examples 'config.yml', 'domainname.tld/whatever.yml', id: 42
```

CLI usage:

```
bundle exec html2rss feed lib/html2rss/configs/domainname.tld/whatever id=42
```

## Programmatic usage

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
