# frozen_string_literal: true

require 'html2rss'
require 'html2rss/configs'
require 'time'
require_relative 'botasaurus_fetch_configs'

##
# Fetches one curated config and judges whether it ships real articles.
#
# Live extraction, the item minimum and the quality audit come from
# Html2rss::Test. This class adds the repo's own bar: links are
# absolute and titles are not navigation or footer chrome. A site that
# refuses the fetch (CDN block, anti-bot interstitial) is reported as
# blocked, not failed, because the refusal says nothing about the config.
class FetchCheck
  MIN_ITEMS = 3

  # Titles that only ever name page chrome, never an article.
  CHROME_TITLE = /\A(?:
    home|start|startseite|news|presse|newsletter|podcast|menu|search|suche|sitemap|
    login|log\ in|sign\ in|contact|kontakt|imprint|impressum|datenschutz|privacy(?:\ policy)?|
    cookies?(?:\ settings)?|accessibility|barrierefreiheit|skip\ to\ (?:main\ )?content|
    utility\ navigation|open\ government\ licence.*
  )\z/xi

  # Menu labels glued together, e.g. "CollectionsPaintings & SculptureDrawings".
  RUN_TOGETHER_TITLE = /[a-zäöü][A-ZÄÖÜ][a-zäöü]+[A-ZÄÖÜ][a-z]/

  BLOCKED_ERROR = 'Html2rss::RequestService::BlockedSurfaceDetected'

  Result = Data.define(:file_name, :status, :item_count, :problems, :newest_published_at, :quality_warnings) do
    def passed? = status == :passed
    def blocked? = status == :blocked
    def skipped? = status == :skipped
  end

  ##
  # @param file_name [String] config path below lib/html2rss/configs, e.g. "kcl.ac.uk/news.yml"
  # @param params [Hash, nil] dynamic parameters; defaults from the config's `parameters` when nil
  # @return [Hash] the config as the fetch runs it, with browser request headers
  def self.config_for(file_name, params = nil)
    config = {}.merge(Html2rss::Configs.find_by_name(file_name))
    config[:headers] = Html2rss::Config::RequestHeaders.browser_defaults.merge(config.fetch(:headers, {}))
    params ||= config.fetch(:parameters, {}).to_h { |name, spec| [name, spec[:default]] }.compact
    config[:params] = params unless params.empty?
    config
  end

  ##
  # @param file_name [String]
  # @param params [Hash, nil]
  # @return [Result]
  def self.call(file_name, params = nil)
    new(file_name, config_for(file_name, params)).call
  end

  def initialize(file_name, config)
    @file_name = file_name
    @config = config
  end

  def call
    return result(:skipped, problems: ['needs BOTASAURUS_SCRAPER_URL']) if botasaurus_unavailable?

    test = Html2rss::Test.call(@config, params: @config.fetch(:params, {}),
                                        min_items: MIN_ITEMS, sample_limit: 10_000)
    return result(:blocked, problems: [test.error_message]) if test.error_message.to_s.include?(BLOCKED_ERROR)

    judge(test)
  rescue StandardError => error # html2rss rescues its own errors; anything else is a broken feed build
    result(:failed, problems: ["#{error.class}: #{error.message}"])
  end

  private

  def botasaurus_unavailable?
    @config[:strategy].to_s == 'botasaurus' && !BotasaurusFetchConfigs.botasaurus_env_configured?
  end

  def judge(test)
    items = test.items || []
    problems = [*test.error_message, *link_problems(items), *chrome_problems(items)]

    result(problems.empty? ? :passed : :failed,
           problems:, item_count: test.item_count, newest_published_at: newest(items),
           quality_warnings: test.quality_report&.warnings&.map(&:to_s) || [])
  end

  def link_problems(items)
    relative = items.reject { |item| item[:url].to_s.start_with?('http') }
    relative.empty? ? [] : ["#{relative.size} items without an absolute http(s) link"]
  end

  def chrome_problems(items)
    chrome = items.map { |item| item[:title].to_s.strip }
                  .select { |title| title.match?(CHROME_TITLE) || title.match?(RUN_TOGETHER_TITLE) }
    return [] if chrome.empty? || chrome.size * 3 < items.size

    ["#{chrome.size} of #{items.size} titles look like navigation: #{chrome.first(3).join(' | ')}"]
  end

  def newest(items)
    items.filter_map { |item| item[:published_at] && Time.iso8601(item[:published_at]) }.max
  end

  def result(status, problems:, item_count: 0, newest_published_at: nil, quality_warnings: [])
    Result.new(file_name: @file_name, status:, item_count:, problems:, newest_published_at:, quality_warnings:)
  end
end
