# frozen_string_literal: true

require 'yaml'
require 'json'

module Html2rss
  module Configs
    module Helper
      def self.url_to_directory_name(url)
        URI(url.split('/')[0..2].join('/')).host.gsub(/^(api|www)\./, '')
      end

      def self.url_to_file_name(url)
        path = begin
          URI(url).path
        rescue URI::InvalidURIError
          url.split('/')[3..-1].join('_')
        end

        (['', '/'].include?(path) ? 'index' : path[1..-1]).tr('.~/:<>|%*[]()!@#$', '_')
      end

      def self.print_markdown(markdown)
        puts TTY::Markdown.parse markdown
      end

      def self.pretty_print(lang, code)
        print_markdown ["```#{lang}", code, '```'].join("\n")
      end

      ##
      # Generates YAML without class annotations (e.g. HashWithIndifferentAccess)
      # by using most simple data structure types (Array, Hash, etc).
      def self.to_simple_yaml(hash)
        # watch this poor dump/parse/dump approach:
        YAML.dump JSON.parse(JSON.generate(hash))
      end
    end
  end
end
