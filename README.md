# html2rss-configs

This repository contains [html2rss](https://github.com/gildesmarais/html2rss)
configs for several websites.

[Find all provided configs in `configs/`.](https://github.com/gildesmarais/html2rss-configs/tree/master/lib/html2rss/configs)

The recommended method to use them is via [html2rss-web](https://github.com/gildesmarais/html2rss-web).

## Usage via html2rss-web

If you're running [html2rss-web](https://github.com/gildesmarais/html2rss-web),
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

## Contributions

Contributions are more than welcome!

### Adding a new config.yml

1. create a yml file in `lib/html2rss/configs/domainname.tld/whatever.yml`.
2. create a rspec file in `spec/html2rss/configs/domainname.tld/whatever.yml_spec.rb`.

The yml file only requires a `channel` and a `selectors` object.

Peek into the existing files and the [html2rss test config](https://github.com/gildesmarais/html2rss/blob/master/spec/config.test.yml).

Modified or added configs will be used on CI to fetch the feed and check
for the presence of feed items.

See [.travis.yml -> scripts](https://github.com/gildesmarais/html2rss-configs/blob/master/.travis.yml) which commands will be executed during build.

### Gotchas and tips & tricks

When creating a config,

- check that the channel URL does not redirect to a mobile page with a different
  markup structure.
- fiddling with [`curl`](https://github.com/curl/curl) and
  [`pup`](https://github.com/ericchiang/pup) to find the selectors seems quite
  efficient.
