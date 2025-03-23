# frozen_string_literal: true

require 'yaml'

RSpec.shared_examples 'config.yml' do |file_name, params|
  subject(:yaml) { YAML.safe_load_file(file_path) }

  let!(:file_path) do
    File.expand_path(File.join(__dir__, '..', '..', '..', 'lib', 'html2rss', 'configs', file_name))
  end

  let(:global_config) do
    {
      'headers' => {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:67.0) Gecko/20100101 Firefox/67.0'
      }
    }
  end
  let(:config) do
    feed_name = file_path.split(File::Separator)[-2..].join(File::Separator)
    config = {}.merge Html2rss::Configs.find_by_name(feed_name)

    config.merge!(global_config)
    config[:params] = params if params
    config
  end

  context 'with the file' do
    let(:host_name) { Helper.url_to_directory_name yaml['channel']['url'] }
    let(:dirname) { File.dirname(file_path).split(File::Separator).last }

    it 'is parseable' do
      expect { yaml }.not_to raise_error
    end

    it "resides in a folder named after channel.url's host" do
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
        it 'references available selectors only', :aggregate_failures do
          Helper.referenced_selectors_in_template(yaml['selectors']).each do |referenced_selector|
            next if referenced_selector == 'self'

            expect(yaml['selectors'][referenced_selector])
              .not_to be_nil, "selector `#{referenced_selector}` referenced, but is missing"
          end
        end
      end

      context 'with categories' do
        it 'references available selectors only', :aggregate_failures do
          yaml['selectors'].fetch('categories', []).each do |selector_name|
            expect(yaml['selectors'][selector_name])
              .not_to be_nil, "categories references `#{selector_name}`, but is missing"
          end
        end
      end
    end
  end

  context "when fetching #{params}", :fetch do
    subject(:feed) { Html2rss.feed(config) }

    it 'has positive amount of items' do
      expect(feed.items.count).to be_positive, <<~MSG
        No items fetched.
        Check the feed URL and selectors in `#{file_name}`.

        # #{file_name}
        #{config}

        # resulted in RSS:
        #{feed}
      MSG
    end
  end

  context "when fetching #{params} / item", :fetch do
    subject(:item) do
      items = Html2rss.feed(config).items

      expect(items.count).not_to be_zero, "Zero items fetched for `#{file_name}`"

      items.shift
    end

    let(:specified_attributes) { Html2rss::Selectors::ITEM_TAGS & %w[title description author category] }
    let(:text_attributes) { specified_attributes & %w[title description author] }

    it 'has no empty text attributes', :aggregate_failures do
      text_attributes.each do |attribute_name|
        expect(item.public_send(attribute_name).to_s).not_to be_empty, attribute_name.to_s
      end
    end

    it 'has no empty content attributes', :aggregate_failures do
      (specified_attributes - text_attributes).each do |attribute_name|
        expect(item.public_send(attribute_name).content).not_to be_empty, attribute_name.to_s
      end
    end

    it 'has link content beginning with "http" when config has a link selector' do
      expect(item&.link&.to_s).to start_with('http') if Html2rss::Selectors::ITEM_TAGS.include?(:url)
    end
  end
end
