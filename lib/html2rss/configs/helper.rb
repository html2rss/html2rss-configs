# frozen_string_literal: true

require 'htmlbeautifier'
require 'json'
require 'nokogiri'
require 'tty-markdown'
require 'yaml'

module Html2rss
  module Configs
    module Helper
      ##
      # @param url [String]
      # @return [String]
      def self.url_to_directory_name(url)
        URI(url.split('/')[0..2].join('/')).host.gsub(/^(api|www)\./, '')
      end

      ##
      # @param url [String]
      # @return [String]
      def self.url_to_file_name(url)
        path = begin
          URI(url).path
        rescue URI::InvalidURIError
          url.split('/')[3..-1].join('_')
        end

        (['', '/'].include?(path) ? 'index' : replace_forbidden_characters_in_filename(path[1..-1]))
      end

      FORBIDDEN_FILENAME_CHARACTERS = '.~/:<>|%*[]()!@#$ '

      ##
      # Replaces all characters in `FORBIDDEN_FILENAME_CHARACTERS` in `name`
      # and replaces it with `replacement`.
      # @param name [String]
      # @param replacement [String] a single character
      # @return [String]
      def self.replace_forbidden_characters_in_filename(name, replacement = '_')
        raise 'replacement must be a single character' if replacement.chr != replacement.to_s
        raise ArgumentError if FORBIDDEN_FILENAME_CHARACTERS.include?(replacement)

        name.tr(FORBIDDEN_FILENAME_CHARACTERS, replacement.chr)
      end

      ##
      # Prints nicely formatted markdown to `output`.
      #
      # @param markdown [String]
      # @return [nil]
      def self.print_markdown(markdown, output: $stdout)
        output.puts TTY::Markdown.parse markdown
      end

      ##
      # Prints nicely formatted code to `output` by wrapping it in a
      # markdown code block and `.print_markdown`.
      #
      # If lang is :html, it beautifies the code
      #
      # @param lang [Symbol] e.g. :html, :yaml, :ruby, ...
      # @param code [String]
      # @return [nil]
      def self.pretty_print(lang, code, output: $stdout)
        return code if code&.to_s == ''

        code = HtmlBeautifier.beautify(code) if lang == :html

        print_markdown ["```#{lang}", code, '```'].join("\n"), output: output
      end

      ##
      # Generates YAML without class annotations (e.g. HashWithIndifferentAccess)
      # by using most simple data structure types (Array, Hash, etc).
      def self.to_simple_yaml(hash)
        # watch this poor dump/parse/dump approach:
        YAML.dump JSON.parse(JSON.generate(hash))
      end

      ##
      # Removes tags which match `selectors_to_remove`.
      # Goal is to reduce cruft in the HTML which is irrelevant to building a
      # RSS feed.
      #
      # @param html [String]
      # @return [Nokogiri::HTML::Document]
      def self.strip_down_html(html, selectors_to_remove = %w[style noscript script svg])
        # Make the beautification more beautiful:
        # force line breaks after/before angle brackets.
        messy_html = html.gsub('<', "\n<").gsub!('>', ">\n")

        doc = Nokogiri.HTML(messy_html, &:noblanks)
        doc.css(selectors_to_remove.join(', ')).each(&:remove)

        remove_empty_html_tags(doc)
        doc
      end

      ##
      # Removes empty html tags by recursively traversing all nodes in `doc`.
      #
      # @param doc [Nokogiri::HTML::Document]
      # @return [Nokogiri::HTML::Document]
      def self.remove_empty_html_tags(doc)
        doc.children.each do |child|
          remove_empty_html_tags(child)
          child.remove if child.text && child.text.gsub(/\s+/, '').empty?
        end
        doc
      end
    end
  end
end
