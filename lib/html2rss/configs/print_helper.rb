# frozen_string_literal: true

%w[htmlbeautifier tty-markdown].each do |optional_dep|
  require optional_dep
rescue LoadError
  warn "The #{optional_dep} gem is unavailable. Install it as a dependency in your project, if you'd like to use it."
end

module Html2rss
  module Configs
    ##
    # A collection of methods helping with printing.
    module PrintHelper
      ##
      # Prints nicely formatted markdown to `output`.
      #
      # @param markdown [String]
      # @return [nil]
      def self.markdown(markdown, output: $stdout)
        if Object.const_defined?('TTY::Markdown')
          output.puts TTY::Markdown.parse markdown
        else
          output.puts markdown
        end
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
      def self.code(lang, code, output: $stdout)
        return code if code&.to_s == ''

        code = HtmlBeautifier.beautify(code) if Object.const_defined?('HtmlBeautifier') && lang == :html

        markdown ["```#{lang}", code, '```'].join("\n"), output:
      end

      ##
      # Pretty prints a Nokogiri::Element and highlights the selector
      #
      # @param selector [String]
      # @param tag [Nokogiri::Node]
      # @param warn_on_multiple [true, false]
      # @param warn_on_single [true, false]
      # @return [nil]
      def self.tag(selector, tag, warn_on_multiple: true, warn_on_single: false)
        tag_count = tag.count

        if warn_on_multiple && tag_count > 1
          markdown <<~MARKDOWN
            ***
            `#{selector}` selects multiple elements!
            Please write a selector as precise as possible to select just one element.
            ***
          MARKDOWN
        elsif warn_on_single && tag_count == 1
          markdown <<~MARKDOWN
            ***
            `#{selector}` selects just one element!
            Please broaden the selector to select multiple elements.
            ***
          MARKDOWN
        end

        markdown "**The selector `#{selector}` selects:**"
        code :html, tag&.to_xhtml
        nil
      end
    end
  end
end
