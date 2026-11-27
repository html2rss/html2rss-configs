# frozen_string_literal: true

require 'yaml'

RSpec.shared_examples 'config.yml' do |file_name, params|
  subject(:yaml) { YAML.safe_load_file(file_path) }

  let!(:file_path) do
    File.expand_path(File.join(__dir__, '..', '..', '..', 'lib', 'html2rss', 'configs', file_name))
  end

  context 'with the file' do
    let(:host_name) { Helper.url_to_host_name yaml['channel']['url'] }
    let(:domain_name) { Helper.url_to_registrable_domain yaml['channel']['url'] }
    let(:dirname) { File.dirname(file_path).split(File::Separator).last }

    it 'is parseable' do
      expect { yaml }.not_to raise_error
    end

    it "resides in a folder named after channel.url's host or domain" do
      expect([domain_name, host_name]).to include(dirname)
    end
  end

  context 'with file contents' do
    it 'has channel and selectors', :aggregate_failures do
      expect(yaml).to have_key 'channel'
      expect(yaml).to have_key 'selectors'
    end

    context 'with directory present' do
      it 'has non-empty topics from the controlled vocabulary', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        expect(yaml).to have_key('directory')
        topics = yaml.dig('directory', 'topics')
        expect(topics).to be_an(Array)
        expect(topics).not_to be_empty

        vocabulary = Html2rss::Config::Validator::DIRECTORY_TOPICS
        topics.each do |topic|
          expect(vocabulary).to include(topic), "unknown topic `#{topic}` (allowed: #{vocabulary.join(', ')})"
        end
      end
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

    context 'with parameters present' do
      it 'has valid parameter definitions', :aggregate_failures do
        yaml['parameters']&.each do |param_name, param_config|
          expect(param_config).to be_a(Hash), "parameter `#{param_name}` should be a hash"
          expect(param_config['type']).to eq('string'), "parameter `#{param_name}` should have type 'string'"
          expect(param_config['default']).not_to be_nil, "parameter `#{param_name}` should have a default value"
        end
      end
    end

    context 'with selectors present' do
      it 'has required selectors', :aggregate_failures do
        expect(yaml['selectors']['items']).not_to be_empty
        expect(yaml['selectors']['title']).not_to be_empty unless yaml.dig('selectors', 'items', 'enhance')
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
    subject(:check) { FetchCheck.call(file_name, params) }

    it 'ships enough real articles' do
      skip(check.problems.join('; ')) if check.blocked? || check.skipped?

      expect(check.problems).to be_empty, <<~MSG
        `#{file_name}` fetched #{check.item_count} items:
        #{check.problems.map { |problem| "- #{problem}" }.join("\n")}
      MSG
    end
  end
end
