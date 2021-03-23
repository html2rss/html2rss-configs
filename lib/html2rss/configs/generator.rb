# frozen_string_literal: true

require 'io/console'
require 'html2rss'
require_relative 'generator/questionnaire'
require_relative './helper'

module Html2rss
  module Configs
    module Generator
      RSPEC_TEMPLATE = <<~RSPEC
        # frozen_string_literal: true

        RSpec.describe '%<relative_yml_file_path>s' do
          include_examples 'config.yml', '%<relative_yml_file_path>s'
        end
      RSPEC

      def self.start
        questionnaire = Questionnaire.new
        questionnaire.ask_questions

        # TODO: move this to a question
        puts 'This is your config:'
        # TODO: prettyprint
        puts questionnaire.to_yaml
        puts
        # TODO: use prompt.yes?
        puts 'Would you like to create a file alongside a corresponding spec for this feed config? [y/N]'

        save_to_files(questionnaire) if $stdin.getch.casecmp('y').zero?
      end

      # TODO: move this to questionnaire or a question
      def self.save_to_files(questionnaire)
        files = files(questionnaire.channel_url)
        write_to_yml(files, questionnaire.to_yaml)
        scaffold_spec(files)
        print_files(files)
      end

      # rubocop:disable Metrics/AbcSize
      def self.print_files(files)
        puts "\nCreated feed config at:"
        puts "  #{files[:yml_file].gsub(files[:gem_root], '')[1..-1]}"
        puts
        puts 'Created spec at:'
        puts "  #{files[:spec_file].gsub(files[:gem_root], '')[1..-1]}"
        puts
        puts 'You can edit them with your editor.'
        puts "Test with:\n  bundle exec html2rss feed #{files[:yml_file].gsub(files[:gem_root], '')[1..-1]}"
      end
      # rubocop:enable Metrics/AbcSize

      def self.write_to_yml(files, yaml)
        raise 'yml file already exists' if File.exist? files[:yml_file]

        FileUtils.mkdir_p files[:yml_dir]
        File.open(files[:yml_file], 'w') { |file| file.write yaml }
      end

      def self.scaffold_spec(files)
        raise 'spec file already exists' if File.exist? files[:spec_file]

        FileUtils.mkdir_p files[:spec_dir]
        File.open(files[:spec_file], 'w') { |file| file.write format(RSPEC_TEMPLATE, files) }
      end

      # rubocop:disable Metrics/MethodLength
      def self.files(channel_url)
        gem_root = File.expand_path(File.join(__dir__, '../../..'))

        dir = Helper.url_to_directory_name(channel_url)
        file = Helper.url_to_file_name(channel_url)

        yml_dir = File.join(gem_root, 'lib/html2rss/configs/', dir)
        spec_dir = File.join(gem_root, 'spec/html2rss/configs', dir)

        {
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
