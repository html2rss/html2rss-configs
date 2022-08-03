# frozen_string_literal: true

require 'html2rss/configs/generator'
require 'html2rss/configs/generator/state'
require 'tty-prompt'
require 'faraday'

RSpec.describe Html2rss::Configs::Generator do
  it { expect(described_class).to be_a(Module) }

  describe '.start' do
    let(:prompt) { TTY::Prompt.new(input:) }
    let(:state) { Html2rss::Configs::Generator::State.new(feed: {}) }
    let(:options) { { path: 'spec.path', question: 'Path?' } }

    let(:input) do
      StringIO.new([
        # channel url
        "https://example.com/blog\n",
        # ITEMS selector
        "\n",
        # confirm selector
        "\n",
        # TITLE selector
        "\n",
        # extractor
        "\n",
        # confirm extractor
        "\n",
        # confirm selector
        "\n",
        # LINK selector
        "\n",
        # extractor
        "href\n",
        # confirm extractor
        "\n",
        # confirm selector
        "\n",
        # DESCRIPTION selector
        "\n",
        # extractor
        "html\n",
        # confirm extractor
        "\n",
        # confirm selector
        "\n",
        # final 'create files' question
        "no\n"
      ].join)
    end

    let(:generated_feed_config) do
      {
        'channel' => {
          'url' => 'https://example.com/blog', 'language' => 'de', 'ttl' => 360, 'time_zone' => 'UTC'
        },
        'selectors' => {
          'items' => { 'selector' => 'article' },
          'title' => { 'selector' => '[itemprop=headline]' },
          'link' => { 'extractor' => :href, 'selector' => 'a:first' },
          'description' => {
            'extractor' => :html,
            'post_process' => [{ 'name' => :sanitize_html }],
            'selector' => '[itemprop=description]'
          }
        }
      }
    end

    let(:body) do
      <<~HTML
        <!DOCTYPE html>
        <html lang="de">
        <head>
          <title>Es war einmal</title>
        </head>
        <body>
          <article>
            <h1 itemprop="headline">Eine Überschrift</h1>
            <p itemprop="description">Mit <b>einem</b> Teaser.</p>
            <a href="#">Und einem relativen Link.</a>
          </article>
        </body>
        </html>
      HTML
    end

    let(:faraday) do
      instance_double(Faraday::Connection,
                      get: instance_double(Faraday::Response, success?: true, body:))
    end

    before do
      allow(Faraday).to receive(:new).and_return(faraday)
    end

    it 'generates a config with default values' do
      expect { described_class.start(prompt, state) }
        .to change { state.fetch(:feed) }
        .from({})
        .to(generated_feed_config)
    end
  end
end
