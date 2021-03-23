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
          Generator.pretty_print :html, HtmlBeautifier.beautify(doc.to_xhtml)
        end

        def validate(input)
          item = doc.css(input)&.first

          return false unless item

          state.store('item', item)

          print_tag(input, item)

          ask_yes_no_with_yes_default("Use selector `#{input}`?")
        end

        def doc
          state.fetch('doc')
        end
      end
    end
  end
end
