# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'html2rss'
# gem 'html2rss', path: '../html2rss'

group :development do
  # gem 'html2rss-generator', path: '../generator'
  gem 'html2rss-generator', github: 'html2rss/generator', branch: :main
end

gemspec
