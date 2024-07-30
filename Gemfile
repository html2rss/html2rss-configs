# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :development do
  # gem 'html2rss-generator', path: '../generator'
  gem 'html2rss-generator', github: 'html2rss/generator', branch: :main

  gem 'nokogiri'
  gem 'rspec', '~> 3.0'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
end

gemspec
