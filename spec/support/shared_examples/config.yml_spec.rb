# frozen_string_literal: true

require 'html2rss/configs/helper'
require 'tzinfo'

RSpec.shared_examples 'config.yml' do |file_name, params|
  subject(:yaml) { YAML.safe_load(file) }

  let!(:file) do
    path = File.expand_path(File.join(__dir__, '..', '..', '..', 'lib', 'html2rss', 'configs', file_name))
    File.open(path)
  end

  let(:feed_name) { file.path.split(File::Separator)[-2..].join(File::Separator) }

  context 'with the file' do
    it 'is parseable' do
      expect { yaml }.not_to raise_error
    end

    it "resides in a folder named after channel.url's host" do
      dirname = File.dirname(file.path).split(File::Separator).last
      host_name = Html2rss::Configs::Helper.url_to_directory_name yaml['channel']['url']

      expect(dirname).to eq(host_name)
    end
  end

  context 'with file contents' do
    it 'has channel and selectors', :aggregate_failures do
      expect(yaml).to have_key 'channel'
      expect(yaml).to have_key 'selectors'
    end

    context 'with channel present' do
      it 'has channel required attributes', :aggregate_failures do
        %w[url ttl time_zone].each do |required_attribute|
          expect(yaml['channel']).to(have_key(required_attribute), required_attribute)
        end
      end

      it 'has a known time_zone' do
        expect { TZInfo::Timezone.get yaml['channel']['time_zone'] }.not_to raise_error
      end
    end

    context 'with selectors present' do
      it 'has required selectors', :aggregate_failures do
        %w[items title].each do |required_attribute|
          expect(yaml['selectors'][required_attribute]).not_to(be_empty, required_attribute)
        end
      end

      context 'with sanitize_html post_processor' do
        it 'is used for description selector' do
          if (description_selector = yaml['selectors']['description'])
            post_processors = [description_selector['post_process']].flatten.compact
            sanitize_html = post_processors.select { |p| p['name'] == 'sanitize_html' }

            expect(sanitize_html).not_to be_nil
          end
        end
      end

      context 'with template post_processor' do
        it 'references available selectors only', aggregate_failures: true do
          Html2rss::Configs::Helper.referenced_selectors_in_template(yaml['selectors']).each do |referenced_selector|
            next if referenced_selector == 'self'

            expect(yaml['selectors'][referenced_selector])
              .not_to be_nil, "selector `#{referenced_selector}` referenced, but is missing"
          end
        end
      end

      context 'with categories' do
        it 'references available selectors only', aggregate_failures: true do
          yaml['selectors'].fetch('categories', []).each do |selector_name|
            expect(yaml['selectors'][selector_name])
              .not_to be_nil, "categories references `#{selector_name}`, but is missing"
          end
        end
      end
    end
  end

  context "with fetching #{params}", :fetch do
    subject(:feed) { Html2rss.feed(config) }

    let(:global_config) do
      {
        'headers' => {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:67.0) Gecko/20100101 Firefox/67.0'
        }
      }
    end
    let(:feed_config) { Html2rss::Configs.find_by_name(feed_name) }
    let(:config) { Html2rss::Config.new(feed_config, global_config, (params || {})) }

    it 'has positive amount of items' do
      expect(feed.items.count).to be_positive
    end

    context 'with an item' do
      let(:item) { feed.items.first }
      let(:specified_attributes) { %w[title description author category] & config.attribute_names }
      let(:text_attributes) { %w[title description author] & specified_attributes }
      let(:content_attributes) { specified_attributes - text_attributes }
      let(:special_attributes) do
        [].tap { |arr| arr << :pubDate if config.attribute_names.include?(:updated) }
      end

      it 'has no empty text or content attributes', :aggregate_failures do
        (text_attributes + special_attributes).each do |attribute_name|
          expect(item.public_send(attribute_name).to_s).not_to be_empty, attribute_name.to_s
        end

        content_attributes.each do |attribute_name|
          expect(item.public_send(attribute_name).content).not_to be_empty, attribute_name.to_s
        end
      end

      it 'has link content beginning with "http" when config has a link selector' do
        expect(item&.link&.to_s).to start_with('http') if config.attribute_names.include?(:link)
      end
    end
  end
end
