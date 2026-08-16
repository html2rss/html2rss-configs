# frozen_string_literal: true

module BotasaurusFetchConfigs
  CONFIGS = %w[
    apple.com/newsroom.yml
    aspi.org.au/strategist.yml
    bundesregierung.de/pressemitteilungen.yml
    carnegieendowment.org/research.yml
    chathamhouse.org/research-publications.yml
    ethz.ch/eth-news.yml
    iiss.org/online-analysis.yml
    imdb.com/ratings.yml
    ntu.edu.sg/news.yml
    oecd.org/newsroom.yml
    opec.org/press-releases.yml
    stackoverflow.com/hot_network_questions.yml
    support.apple.com/en_gb_ht201222.yml
    thoughtworks.com/insights.yml
    who.int/news.yml
    worldbank.org/news.yml
    www.consilium.europa.eu/press-releases.yml
    www.europarl.europa.eu/press-room.yml
  ].freeze

  module_function

  def botasaurus_env_configured?
    !ENV['BOTASAURUS_SCRAPER_URL'].to_s.empty?
  end
end
