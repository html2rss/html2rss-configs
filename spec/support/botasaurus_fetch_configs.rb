# frozen_string_literal: true

module BotasaurusFetchConfigs
  CONFIGS = %w[
    apple.com/newsroom.yml
    deepmind.google/blog.yml
    deraktionaer.de/meistgelesen.yml
    elastic.co/elasticsearch-release-notes.yml
    go.dev/release-history.yml
    grafana.com/whatsnew.yml
    iaapa.org/news.yml
    mozilla.org/security-advisories.yml
    notion.com/blog.yml
    shopify.com/blog.yml
    spotify.com/newsroom.yml
    tourismusnetzwerk-brandenburg.de/aktuelle_nachrichten.yml
  ].freeze

  module_function

  def include?(file_name)
    CONFIGS.include?(file_name)
  end

  def botasaurus_env_configured?
    !ENV['BOTASAURUS_SCRAPER_URL'].to_s.empty?
  end
end
