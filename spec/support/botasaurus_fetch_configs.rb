# frozen_string_literal: true

module BotasaurusFetchConfigs
  CONFIGS = %w[
    apple.com/newsroom.yml
    imdb.com/ratings.yml
    stackoverflow.com/hot_network_questions.yml
    support.apple.com/en_gb_ht201222.yml
    thoughtworks.com/insights.yml
  ].freeze

  module_function

  def botasaurus_env_configured?
    !ENV['BOTASAURUS_SCRAPER_URL'].to_s.empty?
  end
end
