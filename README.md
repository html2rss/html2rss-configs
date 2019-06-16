# html2rss-configs

This repository contains [html2rss](https://github.com/gildesmarais/html2rss)
configs for several websites.

[Find all provided configs in `configs/`.](https://github.com/gildesmarais/html2rss-configs/tree/master/lib/html2rss/configs)

## Usage from html2rss-web

If you're using [html2rss-web](https://github.com/gildesmarais/html2rss-web),
you have nothing more to do! 🎉

Request a feed via: `/domainname.tld/whatever.rss`.

Your full URL might looks like this:
`http://my.server/html2rss/domainname.tld/whatever.rss`

## Usage without html2rss-web

Add this line to your Gemfile:

`gem 'html2rss-configs', git: 'https://github.com/gildesmarais/html2rss-configs.git'`

Use it in your code:

```
require 'html2rss/configs'

Html2rss::Configs.find_by_name('domainname.tld/whatever')
```

This will return the feed config as a Hash with String keys.

## Development

All YAML files are linted with [yamllint](https://github.com/adrienverge/yamllint).
More specific linting of configs will surely come.

Modified or added configs will additionally `rspec`'d and fetch the feed.

### Adding a new config

1. create a yml file in `lib/html2rss/configs/domainname.tld/whatever.yml`.
2. create a rspec file in `spec/html2rss/configs/domainname.tld/whatever.yml_spec.rb`.

The yml file only requires a `channel` and a `selectors` object.

Peek into the existing files and the [html2rss test config](https://github.com/gildesmarais/html2rss/blob/master/spec/config.test.yml).

Some tips and tricks:

- Check that the channel url does not redirect to a mobile page with different
  markup structure.
- fiddling with [`curl`](https://github.com/curl/curl) and
  [`pup`](https://github.com/ericchiang/pup) to find the selectors seems quite
  efficient

### Check all configs work

Run `bundle exec rspec --tag fetch spec/html2rss/configs`.

## Contributions

Contributions are welcome!
