# frozen_string_literal: true

RSpec.describe BotasaurusFetchConfigs do
  describe '.botasaurus_env_configured?' do
    around do |example|
      original_scraper_url = ENV.fetch('BOTASAURUS_SCRAPER_URL', nil)

      example.run
    ensure
      ENV['BOTASAURUS_SCRAPER_URL'] = original_scraper_url
    end

    it 'accepts when BOTASAURUS_SCRAPER_URL is present' do
      ENV['BOTASAURUS_SCRAPER_URL'] = 'http://localhost:4010'

      expect(described_class.botasaurus_env_configured?).to be(true)
    end

    it 'returns false when BOTASAURUS_SCRAPER_URL is empty' do
      ENV['BOTASAURUS_SCRAPER_URL'] = ''

      expect(described_class.botasaurus_env_configured?).to be(false)
    end

    it 'returns false when BOTASAURUS_SCRAPER_URL is nil' do
      ENV['BOTASAURUS_SCRAPER_URL'] = nil

      expect(described_class.botasaurus_env_configured?).to be(false)
    end
  end

  describe 'CONFIGS' do
    it 'includes all configs that use the botasaurus strategy' do
      botasaurus_files = Dir.glob('configs/**/*.yml').select do |file|
        YAML.load_file(file)['strategy'] == 'botasaurus'
      end
      expected_configs = botasaurus_files.map { |file| file.delete_prefix('configs/') }.sort

      expect(described_class::CONFIGS.sort).to eq(expected_configs)
    end
  end
end
