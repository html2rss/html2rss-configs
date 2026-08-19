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

    it 'includes required wire fields on every entry', :aggregate_failures do
      entry = entries.find { |candidate| candidate.id == 'anthropic.com/news' }

      expect(entry).not_to be_nil
      expect(entry.path).to eq('/anthropic.com/news.rss')
      expect(entry.source).to eq('embedded')
      expect(entry.directory[:title]).to eq('Anthropic — News')
      expect(entry.channel[:title]).to eq('Anthropic — News')
      expect(entry.parameters).to eq(schema: {}, defaults: {})
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
