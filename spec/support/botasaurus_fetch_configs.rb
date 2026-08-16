# frozen_string_literal: true

module BotasaurusFetchConfigs
  CONFIGS = %w[
    apple.com/newsroom.yml
    imdb.com/ratings.yml
    stackoverflow.com/hot_network_questions.yml
    thoughtworks.com/insights.yml
  ].freeze

  module_function

  def botasaurus_env_configured?
    !ENV['BOTASAURUS_SCRAPER_URL'].to_s.empty?
  end
end
