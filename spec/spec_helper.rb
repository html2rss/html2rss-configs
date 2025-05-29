# frozen_string_literal: true

require 'bundler/setup'
require 'tzinfo'
require 'html2rss'
require 'html2rss/configs'

Dir['./spec/support/**/*.rb'].each { |f| require f }

Zeitwerk::Loader.eager_load_all

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.filter_run_excluding fetch: true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
