# frozen_string_literal: true

RSpec.describe Html2rss::Configs::Helper do
  let(:messy_html) do
    <<~HTML
      <!DOCTYPE html>
      <html><head><title>Can't make something up</title></head><body>
        <p>Foo goes into a bar and... buz</p>
        <div><span></span></div>
        <script type="text/javascript">alert('lol');</script>
      </body></html>
    HTML
  end

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

  describe '.to_simple_yaml(hash)' do
    subject(:returned_string) { described_class.to_simple_yaml(hash) }

    let(:hash) do
      { foo: {
        bar: :baz
      } }
    end

    let(:yml) do
      <<~YML
        ---
        foo:
          bar: baz
      YML
    end

    it {
      expect(returned_string).to eq yml
    }
  end

  describe '.strip_down_html(html, selectors_to_remove)' do
    let(:html) do
      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>
        Can't make something up
        </title>
        </head>
        <body><p>
        Foo goes into a bar and... buz
        </p></body>
        </html>
      HTML
    end

    it do
      expect(described_class.strip_down_html(messy_html).to_s).to eq html
    end
  end

  describe '.remove_empty_html_tags(doc)' do
    let(:html) do
      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Can't make something up</title>
        </head>
        <body>
        <p>Foo goes into a bar and... buz</p>
        <script type="text/javascript">alert('lol');</script>
        </body>
        </html>
      HTML
    end

    it do
      expect(described_class.remove_empty_html_tags(Nokogiri::HTML(messy_html)).to_s).to eq html
    end
  end

  describe '.string_formatting_references(string)' do
    # rubocop:disable Style/FormatStringToken
    {
      '/%<id>s/episodes/player' => { 'id' => String },
      '%<section>s/%<filter>s' => { 'section' => String, 'filter' => String },
      '/%<id>s/episodes/%{another_id}d' => { 'id' => String, 'another_id' => Numeric },
      'https://github.com/%<user_name>s/%<repository>s/releases' => { 'user_name' => String, 'repository' => String },
      'https://github.com/%{username}s/%{repository}s/releases' => { 'username' => String, 'repository' => String }
    }.each_pair do |string, expected|
      it { expect(described_class.string_formatting_references(string)).to eq expected }
    end
  end
  # rubocop:enable Style/FormatStringToken
end
