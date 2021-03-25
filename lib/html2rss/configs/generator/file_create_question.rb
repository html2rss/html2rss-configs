# frozen_string_literal: true

require_relative './files_and_paths'

module Html2rss
  module Configs
    module Generator
      class FileCreateQuestion
        RSPEC_TEMPLATE = <<~RSPEC
          # frozen_string_literal: true

          RSpec.describe '%<rspec_yml_file_path>s' do
            include_examples 'config.yml', '%<rspec_yml_file_path>s'
          end
        RSPEC

        attr_reader :prompt, :feed_config, :channel_url

        def initialize(prompt, state, **_options)
          @prompt = prompt
          @state = state
          @feed_config = state.fetch('feed')
          @channel_url = @feed_config.dig(:channel, :url)
        end

        def ask
          print_feed_config
          return unless prompt.yes?('Create YAML and spec files for this feed config?')

          config_name = ask_config_name

          fps = FilesAndPaths.new(
            Helper.replace_forbidden_characters_in_filename(config_name),
            Helper.url_to_directory_name(channel_url)
          )

          create(fps)
        end

        private

        def print_feed_config
          Helper.print_markdown <<~MARKDOWN
            ## The feed config

            ```yaml
            #{Helper.to_simple_yaml(feed_config)}
            ```
          MARKDOWN
        end

        def ask_config_name
          # TODO: show target directory
          prompt.ask('Name this config:', default: Helper.url_to_file_name(channel_url)) do |q|
            q.required true
            q.validate(/^[^.][A-z0-9\-_]+[^.]$/)
            q.modify :downcase
          end
        end

        def create(fps)
          write_to_yml(fps)
          scaffold_spec(fps)
          print_files(fps)
        end

        def print_files(fps)
          Helper.print_markdown <<~MARKDOWN
            Created YAML file at:
              `#{fps.relative_yml_path}`

            Created spec file at:
              `#{fps.relative_spec_path}`

            Generate RSS with:
              `bundle exec html2rss feed #{fps.relative_yml_path}`
          MARKDOWN
        end

        def write_to_yml(fps)
          create_file fps.yml_file, Helper.to_simple_yaml(feed_config)
        end

        def scaffold_spec(fps)
          create_file fps.spec_file, format(RSPEC_TEMPLATE, { rspec_yml_file_path: fps.rspec_yml_file_path })
        end

        def create_file(file_path, content)
          raise 'file exists already' if File.exist? file_path

          FileUtils.mkdir_p File.dirname(file_path)
          File.open(file_path, 'w') { |file| file.write content }
        end
      end
    end
  end
end
