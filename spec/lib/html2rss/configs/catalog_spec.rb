# frozen_string_literal: true

require 'html2rss/configs'

RSpec.describe Html2rss::Configs::Catalog do
  describe '.entries' do
    subject(:entries) { described_class.entries }

    it 'returns sorted embedded catalog entries', :aggregate_failures do
      expect(entries).not_to be_empty
      expect(entries.map(&:id)).to eq(entries.map(&:id).sort)
      expect(entries).to all(be_a(Html2rss::Configs::CatalogEntry))
    end

    context 'with anthropic.com/news' do
      subject(:entry) { entries.find { |candidate| candidate.id == 'anthropic.com/news' } }

      it 'maps anthropic identifiers' do
        expect(entry).to have_attributes(
          id: 'anthropic.com/news',
          path: '/anthropic.com/news.rss',
          source: 'embedded'
        )
      end

      it 'maps anthropic titles and parameters', :aggregate_failures do
        expect(entry.directory[:title]).to eq('Anthropic — News')
        expect(entry.channel[:title]).to eq('Anthropic — News')
        expect(entry.parameters).to eq(schema: {}, defaults: {})
      end
    end
  end

  describe '.build_entry' do
    it 'maps parameterized configs to schema and defaults', :aggregate_failures do
      file_name = Html2rss::Configs.file_names.find { |name| name.end_with?('cnet.com/section_sub.yml') }
      entry = described_class.build_entry(file_name)

      expect(entry.id).to eq('cnet.com/section_sub')
      expect(entry.parameters[:defaults]).to eq('section' => 'tech')
      expect(entry.parameters[:schema]['section']).to eq('type' => 'string')
    end
  end
end
