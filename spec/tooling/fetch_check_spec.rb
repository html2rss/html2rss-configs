# frozen_string_literal: true

RSpec.describe FetchCheck do
  subject(:check) { described_class.new('example.com/news.yml', config).call }

  let(:config) { { channel: { url: 'https://example.com/news' }, selectors: {} } }
  let(:test_result) { fetch_outcome(items: articles) }
  let(:articles) do
    [
      article('Council approves budget', '2026-11-01T00:00:00Z'),
      article('Harbour reopens after storm', '2026-11-20T08:30:00Z'),
      article('Library extends opening hours', nil)
    ]
  end

  before { allow(Html2rss::Test).to receive(:call).and_return(test_result) }

  def article(title, published_at, url: "https://example.com/#{title.downcase.tr(' ', '-')}")
    { title:, url:, published_at: }
  end

  def fetch_outcome(items:, error_message: nil, warnings: [])
    instance_double(Html2rss::Test::Result, items:, item_count: items.size, error_message:,
                                            quality_report: instance_double(Html2rss::Test::QualityReport, warnings:))
  end

  context 'with three real articles' do
    it 'passes with the newest date' do
      expect(check).to have_attributes(status: :passed, item_count: 3, problems: [],
                                       newest_published_at: Time.utc(2026, 11, 20, 8, 30))
    end

    it 'asks the gem for the repo minimum' do
      check
      expect(Html2rss::Test).to have_received(:call).with(config, params: {}, min_items: 3, sample_limit: 10_000)
    end
  end

  context 'when the gem reports a failure' do
    let(:test_result) { fetch_outcome(items: [], error_message: 'Extracted 1 items (minimum required: 3)') }

    it 'fails with the gem message' do
      expect(check).to have_attributes(status: :failed, problems: ['Extracted 1 items (minimum required: 3)'])
    end
  end

  context 'when the site blocks the fetch' do
    let(:test_result) do
      fetch_outcome(items: [], error_message: 'Html2rss::RequestService::BlockedSurfaceDetected: Cloudflare')
    end

    it 'is blocked, not failed' do
      expect(check).to be_blocked
    end
  end

  context 'when building the feed raises outside html2rss' do
    before { allow(Html2rss::Test).to receive(:call).and_raise(RSS::NotSetError.new('maker.items', %w[title])) }

    it 'fails with the error' do
      expect(check).to have_attributes(status: :failed, problems: [a_string_starting_with('RSS::NotSetError')])
    end
  end

  context 'when a third of the titles are page chrome' do
    let(:articles) { [*super(), article('Impressum', nil), article('Datenschutz', nil)] }

    it 'fails naming the chrome titles' do
      expect(check.problems).to contain_exactly('2 of 5 titles look like navigation: Impressum | Datenschutz')
    end
  end

  context 'when menu labels run together into one title' do
    let(:articles) { [*super().first(2), article('VisitOpening HoursReaching usMapTickets', nil)] }

    it 'fails' do
      expect(check).to have_attributes(status: :failed)
    end
  end

  context 'when one chrome title sits among many articles' do
    let(:articles) { [*super(), article('Newsletter', nil)] }

    it 'passes' do
      expect(check).to be_passed
    end
  end

  context 'when an item link is relative' do
    let(:articles) { [*super().first(2), article('Port strike ends', nil, url: '/port-strike-ends')] }

    it 'fails' do
      expect(check.problems).to contain_exactly('1 items without an absolute http(s) link')
    end
  end

  context 'with a Botasaurus config and no scraper' do
    let(:config) { super().merge(strategy: 'botasaurus') }

    around do |example|
      original = ENV.delete('BOTASAURUS_SCRAPER_URL')
      example.run
    ensure
      ENV['BOTASAURUS_SCRAPER_URL'] = original
    end

    it 'skips without fetching', :aggregate_failures do
      expect(check).to be_skipped
      expect(Html2rss::Test).not_to have_received(:call)
    end
  end

  describe '.config_for' do
    it 'fills default parameters and browser headers' do
      config = described_class.config_for('reddit.com/subreddit.yml')

      expect(config).to include(params: hash_including(:r), headers: hash_including('User-Agent'))
    end
  end
end
