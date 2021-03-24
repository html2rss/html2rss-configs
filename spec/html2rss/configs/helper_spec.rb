# frozen_string_literal: true

require 'active_support/core_ext/hash'

RSpec.describe Html2rss::Configs::Helper do
  describe '.url_to_directory_name(url)' do
    { 'http://example.com' => 'example.com',
      'http://www.example.com' => 'example.com',
      'http://api.example.com' => 'example.com',
      'http://sapi.example.com' => 'sapi.example.com',
      'http://foobar.example.com' => 'foobar.example.com',
      'http://s5.region.example.com' => 's5.region.example.com' }.each_pair do |url, dirname|
        it { expect(described_class.url_to_directory_name(url)).to eq dirname }
      end
  end

  describe '.url_to_file_name(url)' do
    { 'http://example.com' => 'index',
      'http://www.example.com/' => 'index',
      'http://api.example.com/resource' => 'resource',
      'https://trakt.tv/%<section>s/foo/%<filter>s' => '_section_s_foo___filter_s',
      'http://something.com/~/../../etc/passwd' => '________etc_passwd' }.each_pair do |url, filename|
      it { expect(described_class.url_to_file_name(url)).to eq filename }
    end
  end

  describe '.simple_yaml(hash)' do
    subject(:returned_string) { described_class.simple_yaml(hash) }

    let(:hash) do
      { foo: {
        bar: :baz
      } }.with_indifferent_access
    end

    it {
      expect(returned_string).to eq <<~YML
        ---
        foo:
          bar: baz
      YML
    }
  end
end
