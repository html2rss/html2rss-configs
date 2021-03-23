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
          # TODO: pretty print
          puts HtmlBeautifier.beautify(item.to_xhtml)
          puts
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
          # TODO: pretty print (by using markdown with tty-something)
          if tag.count > 1
            puts '*' * 80
            puts "`#{input}` selects multiple elements! Please write a selector as precise as possible."
            puts '*' * 80
          end
          puts "Match for selector: `#{input}`:"
          puts
          puts HtmlBeautifier.beautify(tag&.to_xhtml)
          puts
        end
      end
    end
  end
end
