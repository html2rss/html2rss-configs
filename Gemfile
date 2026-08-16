# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Path gem until html2rss ships directory.topics validation (feat/directory-topics).
gem 'html2rss', path: '../html2rss'

group :development do
  gem 'nokogiri'
  gem 'public_suffix'
  gem 'rspec', '~> 3.0'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
end

gemspec
