# frozen_string_literal: true

RSpec.describe BrowserlessFetchConfigs do
  describe '.browserless_env_configured?' do
    around do |example|
      original_ws_url = ENV.fetch('BROWSERLESS_IO_WEBSOCKET_URL', nil)
      original_api_token = ENV.fetch('BROWSERLESS_IO_API_TOKEN', nil)

      example.run
    ensure
      ENV['BROWSERLESS_IO_WEBSOCKET_URL'] = original_ws_url
      ENV['BROWSERLESS_IO_API_TOKEN'] = original_api_token
    end

    it 'accepts the documented local Browserless websocket URL without a token' do
      ENV['BROWSERLESS_IO_WEBSOCKET_URL'] = 'ws://127.0.0.1:4002'
      ENV['BROWSERLESS_IO_API_TOKEN'] = ''

      expect(described_class.browserless_env_configured?).to be(true)
    end

    it 'accepts the legacy local Browserless websocket URL without a token' do
      ENV['BROWSERLESS_IO_WEBSOCKET_URL'] = 'ws://127.0.0.1:3000'
      ENV['BROWSERLESS_IO_API_TOKEN'] = ''

      expect(described_class.browserless_env_configured?).to be(true)
    end

    it 'requires a token for non-local websocket URLs' do
      ENV['BROWSERLESS_IO_WEBSOCKET_URL'] = 'wss://production.browserless.example/ws'
      ENV['BROWSERLESS_IO_API_TOKEN'] = ''

      expect(described_class.browserless_env_configured?).to be(false)
    end

    it 'accepts non-local websocket URLs when a token is present' do
      ENV['BROWSERLESS_IO_WEBSOCKET_URL'] = 'wss://production.browserless.example/ws'
      ENV['BROWSERLESS_IO_API_TOKEN'] = 'secret-token'

      expect(described_class.browserless_env_configured?).to be(true)
    end
  end
end
