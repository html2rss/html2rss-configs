# frozen_string_literal: true

module BrowserlessFetchConfigs
  LOCAL_WS_URLS = %w[
    ws://127.0.0.1:3000
    ws://127.0.0.1:4002
  ].freeze

  CONFIGS = %w[
    apple.com/newsroom.yml
    deepmind.google/blog.yml
    notion.com/blog.yml
    shopify.com/blog.yml
    spotify.com/newsroom.yml
  ].freeze

  module_function

  def include?(file_name)
    CONFIGS.include?(file_name)
  end

  def browserless_env_configured?
    ws_url = ENV['BROWSERLESS_IO_WEBSOCKET_URL'].to_s
    return false if ws_url.empty?
    return true if LOCAL_WS_URLS.include?(ws_url)

    !ENV['BROWSERLESS_IO_API_TOKEN'].to_s.empty?
  end
end
