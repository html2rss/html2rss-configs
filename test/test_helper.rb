# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../tool/Gemfile', __dir__)

require 'bundler/setup'
require 'rspec'
require 'tzinfo'
require 'html2rss'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |path| require path }

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.filter_run_excluding fetch: true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
