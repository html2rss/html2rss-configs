# html2rss-configs

This repository contains [html2rss](https://github.com/gildesmarais/html2rss)
configs for several websites.

[Find all provided configs in `configs/`.](https://github.com/gildesmarais/html2rss-configs/tree/master/lib/html2rss/configs)

The recommended method to use them is via [html2rss-web](https://github.com/gildesmarais/html2rss-web).

## Usage via html2rss-web

If you're running [html2rss-web](https://github.com/gildesmarais/html2rss-web),
you have nothing more to do! 🎉

Your full request URL might looks like this:
`http://my.server/html2rss/github.com/nuxt.js_releases.rss`

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

### Adding a new config

There's a generator for that! 🆒

`make config domain=domainname.tld name=whatever`

Change `domain` and `name` values to desired values. Then head to the generated
files and add the selectors etc.

Look around in the existing config.yml files, e.g. the extensive [github.com/nuxt.js_releases.yml](https://github.com/gildesmarais/html2rss-configs/blob/master/lib/html2rss/configs/github.com/nuxt.js_releases.yml).

### Gotchas and tips & tricks

When creating a config,

- check that the channel URL does not redirect to a mobile page with a different
  markup structure.
- fiddling with [`curl`](https://github.com/curl/curl) and
  [`pup`](https://github.com/ericchiang/pup) to find the selectors seems quite
  efficient.

## Building on the CI

Modifying existing or adding new configs will trigger the CI to fetch the feed
and check for the presence of feed items.

See [.travis.yml -> script](https://github.com/gildesmarais/html2rss-configs/blob/master/.travis.yml) which commands will be executed during build.
