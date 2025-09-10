# frozen_string_literal: true

RSpec.describe Html2rss::Configs do
  # Get all YAML config files
  config_files = Dir.glob('lib/html2rss/configs/**/*.yml')

  # Filter by environment variable if specified
  config_files = config_files.select { |f| f.include?(ENV['TEST_CONFIG']) } if ENV['TEST_CONFIG']

  # Filter by RSpec example pattern if specified
  if RSpec.configuration.filter_manager.inclusions.rules[:example]
    pattern = RSpec.configuration.filter_manager.inclusions.rules[:example].first
    config_files = config_files.select { |f| f.include?(pattern) }
  end

  config_files.each do |config_file|
    relative_path = config_file.sub('lib/html2rss/configs/', '')
    config_name = relative_path.tr('/', '_').gsub('.yml', '')
    domain = relative_path.split('/').first

    describe "#{relative_path} (#{config_name})", config: config_name, domain: domain do
      it_behaves_like 'config.yml', relative_path

      # Add debugging hook for specific configs
      if ENV['DEBUG_CONFIG'] == relative_path
        it 'debugs the config' do
          puts "Debugging config: #{relative_path}"
          puts "File path: #{config_file}"
          puts "Config name: #{config_name}"
          puts "Domain: #{domain}"
          expect(relative_path).to be_a(String) # Add meaningful expectation
        end
      end
    end
  end
end
