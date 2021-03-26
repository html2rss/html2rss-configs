# frozen_string_literal: true

require 'htmlbeautifier'
require 'json'
require 'nokogiri'
require 'tty-markdown'
require 'yaml'

module Html2rss
  module Configs
    ##
    # A collection of helper methods.
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
        replacement_chr = replacement.chr
        raise 'replacement must be a single character' if replacement_chr != replacement.to_s
        raise ArgumentError if FORBIDDEN_FILENAME_CHARACTERS.include?(replacement)

        name.tr(FORBIDDEN_FILENAME_CHARACTERS, replacement_chr)
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
          child_text = child.text
          child.remove if child_text && child_text.gsub(/\s+/, '').empty?
        end
        doc
      end

      ##
      # Pretty prints a Nokogiri::Element and highlights the selector
      #
      # @param selector [String]
      # @param tag [Nokogiri::Node]
      # @param warn_on_multiple [true, false]
      # @param warn_on_signel [true, false]
      # @return [nil]
      def self.print_tag(selector, tag, warn_on_multiple: true, warn_on_single: false)
        tag_count = tag.count

        if warn_on_multiple && tag_count > 1
          Helper.print_markdown <<~MARKDOWN
            ***
            `#{selector}` selects multiple elements!
            Please write a selector as precise as possible to select just one element.
            ***
          MARKDOWN
        elsif warn_on_single && tag_count == 1
          Helper.print_markdown <<~MARKDOWN
            ***
            `#{selector}` selects just one element!
            Please broaden the selector to select multiple elements.
            ***
          MARKDOWN
        end

        Helper.print_markdown "**The selector `#{selector}` selects:**"
        Helper.pretty_print :html, tag&.to_xhtml
        nil
      end

      ##
      # Prints helpful debug information to the prompt.
      def self.handle_unsuccessful_http_response(status, headers)
        case status
        when 300..399
          Helper.print_markdown "The url redirects. Try to use `#{headers['location']}`"
        when 400..599
          # client/server error
          Helper.print_markdown <<~MARKDOWN
            Encountered error **`#{status}`**.
            Here are the response headers which could help debugging:

            ```yaml
            #{Helper.to_simple_yaml(headers).gsub("---\n", '').chomp}
            ```
          MARKDOWN
        end
      end

      ##
      # Determines which selectors are referenced in the template of a Html2rss::PostProcessors::Template.
      #
      # @params selectors [Hash<String,Hash>] the 'selectors hash'
      # @return [Array<String>]
      def self.referenced_selectors_in_template(selectors)
        selectors.each_value.flat_map do |selector_hash|
          next unless selector_hash.is_a?(Hash)

          post_processor_hashes(selector_hash['post_process'], 'template').flat_map do |template|
            string_formatting_references template['string']
          end
        end
                 .compact
      end

      ##
      #
      # @param post_process [Hash<Hash>, Array<Hash>]
      # @params keep_name [String]
      # @return [Array<Hash>] containing only the hashes stored under the 'keep_name'
      def self.post_processor_hashes(post_processors, keep_name)
        [post_processors].flatten.compact.keep_if { |processor| processor['name'] == keep_name }
      end

      ##
      #
      # return [Array<String>] the keys of the referenced values of "more complex string formatting"
      def self.string_formatting_references(string)
        string.scan(/%[<|{](\w*)[>|}]/).flatten.uniq
      end
    end
  end
end
