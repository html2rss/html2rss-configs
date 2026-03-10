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
    config_name = config_file.sub('lib/html2rss/configs/', '').tr('/', '_').gsub('.yml', '')
    domain = config_file.sub('lib/html2rss/configs/', '').split('/').first

    describe "#{config_file.sub('lib/html2rss/configs/', '')} (#{config_name})",
             config: config_name,
             domain: domain,
             relative_path: config_file.sub('lib/html2rss/configs/', '') do
      it_behaves_like 'config.yml', config_file.sub('lib/html2rss/configs/', '')
    end
  end
end
