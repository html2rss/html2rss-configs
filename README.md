# html2rss-configs

This repository contains [html2rss](https://github.com/gildesmarais/html2rss)
configs for several websites.

## Usage

`Html2rss::Configs.find_by_name('domainname.tld/whatever')` returns a Hash.

## Usage with html2rss-web

If you're using [html2rss-web](https://github.com/gildesmarais/html2rss-web),
you have nothing more to do than adding this to your `config.yml`:

# TODO: add instructions 🙈

Do not forget to fetch the latest version regularly to profit from the changes
made in this repository.

## Creating a new config

Create a file in `lib/html2rss/configs/domainname.tld/whatever.yml`.

Some tips and tricks:

- Check that the channel url does not redirect to a mobile page with different
  markup structure.
- fiddling with [`curl`](https://github.com/curl/curl) and
  [`pup`](https://github.com/ericchiang/pup) to find the selectors seems quite
  efficient

## Development

All YAML files are linted with [yamllint](https://github.com/adrienverge/yamllint).
More specific linting of configs will surely come.

## Contributions

Contributions are welcome!
