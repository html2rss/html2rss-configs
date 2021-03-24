# frozen_string_literal: true

module Html2rss
  module Configs
    module Generator
      class FileCreator
        RSPEC_TEMPLATE = <<~RSPEC
          # frozen_string_literal: true

          RSpec.describe '%<relative_yml_file_path>s' do
            include_examples 'config.yml', '%<relative_yml_file_path>s'
          end
        RSPEC

        attr_reader :feed_config

        def initialize(_prompt, feed_config)
          @feed_config = feed_config
        end

        def create
          # TODO: ask for filename ... suggest defaults determined by on Helper.url_to(directory|file)_name
          write_to_yml
          scaffold_spec
          print_files
        end

        def print_files
          Helper.print_markdown <<~MARKDOWN
            Created feed config at:
                `#{files[:yml_file].gsub(files[:gem_root], '')[1..-1]}`

            Created spec at:
                `#{files[:spec_file].gsub(files[:gem_root], '')[1..-1]}`

            Test with:
                `bundle exec html2rss feed #{files[:yml_file].gsub(files[:gem_root], '')[1..-1]}`
          MARKDOWN
        end

        def write_to_yml
          raise 'yml file exists already' if File.exist? files[:yml_file]

          FileUtils.mkdir_p files[:yml_dir]
          File.open(files[:yml_file], 'w') { |file| file.write Helper.to_simple_yaml(feed_config) }
        end

        def scaffold_spec
          raise 'spec file already exists' if File.exist? files[:spec_file]

          FileUtils.mkdir_p files[:spec_dir]
          File.open(files[:spec_file], 'w') { |file| file.write format(RSPEC_TEMPLATE, files) }
        end

        # rubocop:disable Metrics/MethodLength
        def files
          return @files if defined?(@files)

          channel_url = feed_config.dig(:channel, :url)
          gem_root = File.expand_path(File.join(__dir__, '../../..'))

          dir = Helper.url_to_directory_name(channel_url)
          file = Helper.url_to_file_name(channel_url)

          yml_dir = File.join(gem_root, 'lib/html2rss/configs/', dir)
          spec_dir = File.join(gem_root, 'spec/html2rss/configs', dir)

          @files = {
            gem_root: gem_root,
            relative_yml_file_path: "#{[dir, file].join('/')}.yml",
            spec_dir: spec_dir,
            spec_file: File.join(spec_dir, "#{file}.yml_spec.rb"),
            yml_dir: yml_dir,
            yml_file: File.join(yml_dir, "#{file}.yml")
          }
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
