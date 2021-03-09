# frozen_string_literal: true

require 'htmlbeautifier'
require 'io/console'

require_relative './selector_question'

module Html2rss
  module Configs
    module Generator
      class ItemsSelectorQuestion < SelectorQuestion
        private

        def before_ask
          puts HtmlBeautifier.beautify(doc.to_xhtml)
          puts
        end

        # Show the first item's HTML which would be extracted
        # Display 'key elements' (w/o head, empty tags, link, style, script, etc).
        # without html comments
        def validate(input)
          item = doc.css(input)&.first

          return false unless item

          questionnaire.store('item', item, :meta)

          puts "First match for selector: `#{input}`:"
          puts
          puts HtmlBeautifier.beautify(item&.to_xhtml)
          puts
          puts "Use selector `#{input}`? [Y/n] "

          $stdin.getch.casecmp('y').zero?
        end

        def doc
          questionnaire.fetch('doc')
        end
      end
    end
  end
end
