# frozen_string_literal: true

module BotasaurusFetchConfigs
  CONFIGS = %w[
    aalto.fi/news.yml
    academictransfer.com/jobs.yml
    apple.com/newsroom.yml
    aspi.org.au/strategist.yml
    bundesregierung.de/pressemitteilungen.yml
    carnegieendowment.org/research.yml
    chalmers.se/news.yml
    chathamhouse.org/research-publications.yml
    curia.europa.eu/press-releases.yml
    ethz.ch/eth-news.yml
    hkma.gov.hk/eng_news-and-media_press-releases.yml
    iiss.org/online-analysis.yml
    imdb.com/ratings.yml
    imo.org/press-briefings.yml
    ndl.go.jp/en_news.yml
    ntu.edu.sg/news.yml
    occrp.org/news.yml
    oecd.org/newsroom.yml
    opec.org/press-releases.yml
    panapress.com/latest.yml
    stackoverflow.com/hot_network_questions.yml
    support.apple.com/en_gb_ht201222.yml
    tap.info.tn/politics.yml
    theeastafrican.co.ke/news.yml
    thoughtworks.com/insights.yml
    visitfinland.com/press-releases.yml
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
