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
          Helper.pretty_print :html, HtmlBeautifier.beautify(item.to_xhtml)
        end

        def validate(input)
          tag = item.css(input)

          return false unless tag

          print_tag(input, tag)

          ItemExtractorQuestion.new(prompt, state, path: path, selector: input).ask

          # TODO: print the config and the result before asking

          prompt.yes?("Use this selector config for #{path}?")
        end

        def process(input)
          { selector: input }
        end

        def print_tag(input, tag)
          if tag.count > 1
            Helper.print_markdown <<~MARKDOWN
              ***
              `#{input}` selects multiple elements!
              Please write a selector as precise as possible.
              ***
            MARKDOWN
          end

          Helper.print_markdown "The selector `#{input}` selects:"
          Helper.pretty_print :html, HtmlBeautifier.beautify(tag&.to_xhtml)
        end
      end
    end
  end
end
