# frozen_string_literal: true

RSpec.describe 'configs' do
  config_files = Dir.glob('configs/**/*.yml')

  config_files = config_files.select { |path| path.include?(ENV['TEST_CONFIG']) } if ENV['TEST_CONFIG']

  if RSpec.configuration.filter_manager.inclusions.rules[:example]
    pattern = RSpec.configuration.filter_manager.inclusions.rules[:example].first
    config_files = config_files.select { |path| path.include?(pattern) }
  end

  config_files.each do |config_file|
    config_name = config_file.delete_prefix('configs/').tr('/', '_').gsub('.yml', '')
    domain = config_file.delete_prefix('configs/').split('/').first

    describe "#{config_file.delete_prefix('configs/')} (#{config_name})",
             config: config_name,
             domain: domain,
             relative_path: config_file.delete_prefix('configs/') do
      it_behaves_like 'config.yml', config_file.delete_prefix('configs/')
    end
  end
end
