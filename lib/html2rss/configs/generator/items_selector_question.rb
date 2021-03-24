# frozen_string_literal: true

require 'htmlbeautifier'

require_relative './selector_question'

module Html2rss
  module Configs
    module Generator
      class ItemsSelectorQuestion < SelectorQuestion
        private

        def before_ask
          Helper.pretty_print :html, HtmlBeautifier.beautify(doc.to_xhtml)
        end

        def validate(input)
          item = doc.css(input)&.first

          return false unless item

          state.store('item', item)

          print_tag(input, item)

          prompt.yes?("Use selector `#{input}`?")
        end

        def doc
          state.fetch('doc')
        end
      end
    end
  end
end
