# frozen_string_literal: true

require 'htmlbeautifier'
require 'io/console'

require_relative './question'

module Html2rss
  module Configs
    module Generator
      class SelectorQuestion < Question
        private

        def before_ask
          puts HtmlBeautifier.beautify(item.to_xhtml)
          puts
        end

        def validate(input)
          tag = item.css(input)&.first

          return false unless tag

          puts "First match for selector: `#{input}`:"
          puts
          puts HtmlBeautifier.beautify(tag&.to_xhtml)
          puts
          puts "Use selector `#{input}`? [Y/n] "

          $stdin.getch.casecmp('y').zero?
        end

        def process(input)
          { selector: input }
        end

        def validation_failed(input)
          puts "No match for `#{input}` or was discarded"
        end

        def item
          questionnaire.fetch('item')
        end
      end
    end
  end
end
