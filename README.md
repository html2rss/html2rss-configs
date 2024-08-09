![html2rss logo](https://github.com/html2rss/html2rss/raw/master/support/logo.png)

# html2rss-configs

✌️ This repository contains [`html2rss`](https://github.com/html2rss/html2rss) _feed configs_ for many websites.
👉 Find all _feed configs_ in the [`configs/` directory](https://github.com/html2rss/html2rss-configs/tree/master/lib/html2rss/configs).
☝️ A handy usage method is via [`html2rss-web`](https://github.com/html2rss/html2rss-web).
💪 Contributions are more than welcome!
[Fork this repository](https://help.github.com/en/github/getting-started-with-github/fork-a-repo),
add your _feed config_ and
[create a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).

## Contributing

The html2rss "ecosystem" is a community project. We welcome contributions of all kinds. This includes new feed configs, suggesting and implementing features, providing bug fixes, documentation improvements, and any other kind of help.

### Adding a new feed config

Which way you choose to add a new feed config is up to you. You can do it manually or risk the "wizard-like" generator. Please [submit a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork)!

After you're done, you can test your feed config by running `bundle exec html2rss feed lib/html2rss/configs/<domainname.tld>/<path>.yml`.

#### Prefered way: manually

1. Fork this repo and run `bundle install` (you need to have Ruby >= 3.1 installed).
2. Create a new folder and file following ths convention: `lib/html2rss/configs/<domainname.tld>/<path>.yml`
3. Create the feed config in the `<path>.yml` file.
4. Add this spec file in the `spec/html2rss/configs/<domainname.tld>/<path>_spec.rb` file.

```ruby
  RSpec.describe '<domainname.tld>/<path>' do
    include_examples 'config.yml', described_class
  end
```

#### Using the "wizard-like" generator

There's was a try to build a wizard like TUI based generator for that! 🆒 It hasn't seen much love, tho, but it might gets you going or crash in the middle of the process.

1. Fork this repo and run `bundle install` (you need to have Ruby >= 3.1 installed).
2. Start the generator by typing: `bin/generator`
3. Build your feed config and answer 'y' in the last step to create the files.
4. Optionally, edit the created files. Read [`html2rss`'s README](https://github.com/html2rss/html2rss/blob/master/README.md) to see what is possible or browse [existing configs](https://github.com/html2rss/html2rss-configs/tree/master/lib/html2rss/configs) for inspiration.
5. To test, run:
   `bundle exec html2rss feed lib/html2rss/configs/domainname.tld/whatever`

## Using dynamic parameters in `channel` attributes

When you're using dynamic parameters, you have to provide the parameters to the spec, too:

```ruby
include_examples 'config.yml', 'domainname.tld/whatever.yml', id: 42
```

CLI usage:

```sh
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

If you're running [`html2rss-web`](https://github.com/html2rss/html2rss-web),
you have nothing more to do! 🎉 Just request them from your instance at path: `/<domainname.tld/path>.rss` and you'll be served the RSS.

## CI: Building on the CI

Modifying existing or adding new _feed configs_ will trigger the CI to fetch the feed
and check for the presence of feed items.
