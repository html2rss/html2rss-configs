require 'bundler/setup'
require 'html2rss'
require 'html2rss/configs'
require 'active_support'
require 'active_support/core_ext/time'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.filter_run_excluding fetch: true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def post_processor_hashes(post_processors, keep_only_name)
    [post_processors].flatten.compact.keep_if { |p| p['name'] == keep_only_name }
  end

  def format_sequences(string)
    string.scan(/%[<|{](\w*)[>|}]/)
  end

  def selectors_in_template(selectors)
    selectors.each_value.map do |selector_hash|
      next unless selector_hash.is_a?(Hash)

      post_processor_hashes(selector_hash['post_process'], 'template').map do |template|
        format_sequences template['string']
      end
    end
             .flatten
             .compact
  end
end
