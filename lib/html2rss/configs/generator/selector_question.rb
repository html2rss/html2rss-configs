# frozen_string_literal: true

require 'htmlbeautifier'
require 'io/console'

require_relative './question'
require_relative './item_extractor_question'

module Html2rss
  module Configs
    module Generator
      class SelectorQuestion < Question
        private

        def before_ask
          Generator.pretty_print :html, HtmlBeautifier.beautify(item.to_xhtml)
        end

        def validate(input)
          tag = item.css(input)

          return false unless tag

          print_tag(input, tag)

          ItemExtractorQuestion.new(state, path: path, selector: input).ask

          ask_yes_no_with_yes_default("Use this selector config for #{path}?")
        end

        def process(input)
          { selector: input }
        end

        def print_tag(input, tag)
          lines = []
          if tag.count > 1
            lines << '*' * 80
            lines << "`#{input}` selects multiple elements! Please write a selector as precise as possible."
            lines << '*' * 80
          end
          lines << "Match for selector: `#{input}`:"

          Generator.print_markdown lines.join("\n")
          Generator.pretty_print :html, HtmlBeautifier.beautify(tag&.to_xhtml)
        end
      end
    end
  end
end
