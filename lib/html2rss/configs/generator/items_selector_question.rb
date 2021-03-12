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

        def validate(input)
          item = doc.css(input)&.first

          return false unless item

          state.store('item', item)

          print_tag(input, item)

          puts "Use selector `#{input}`? [Y/n] "
          $stdin.getch.casecmp('y').zero?
        end

        def doc
          state.fetch('doc')
        end
      end
    end
  end
end
