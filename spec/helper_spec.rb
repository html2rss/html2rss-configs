# frozen_string_literal: true

RSpec.describe Helper do
  describe '.url_to_registrable_domain' do
    it 'collapses subdomains to the registrable domain' do
      expect(described_class.url_to_registrable_domain('https://blog.example.com/posts')).to eq('example.com')
    end

    it 'keeps multi-part TLDs intact for registrable domain' do
      expect(described_class.url_to_registrable_domain('https://news.bbc.co.uk/world')).to eq('bbc.co.uk')
    end

    it 'preserves single-host domains' do
      expect(described_class.url_to_registrable_domain('https://example.com')).to eq('example.com')
    end

    it 'returns nil for blank or invalid URLs', :aggregate_failures do
      expect(described_class.url_to_registrable_domain(nil)).to be_nil
      expect(described_class.url_to_registrable_domain('')).to be_nil
      expect(described_class.url_to_registrable_domain('not a url')).to be_nil
    end
  end

  describe '.url_to_host_name' do
    it 'returns the full host' do
      expect(described_class.url_to_host_name('https://news.bbc.co.uk/world')).to eq('news.bbc.co.uk')
    end
  end
end
