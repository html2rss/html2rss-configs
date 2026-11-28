# frozen_string_literal: true

require 'yaml'

##
# Configs that fetch through Botasaurus, read from each config's `strategy`.
module BotasaurusFetchConfigs
  CONFIG_DIR = File.expand_path('../lib/html2rss/configs', __dir__)

  CONFIGS = Dir.glob('**/*.yml', base: CONFIG_DIR)
               .select { |file| YAML.safe_load_file(File.join(CONFIG_DIR, file))['strategy'] == 'botasaurus' }
               .sort.freeze

  module_function

  def botasaurus_env_configured?
    !ENV['BOTASAURUS_SCRAPER_URL'].to_s.empty?
  end
end
