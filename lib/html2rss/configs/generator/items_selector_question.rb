# frozen_string_literal: true

require_relative './selector_question'

module Html2rss
  module Configs
    module Generator
      class ItemsSelectorQuestion < SelectorQuestion
        private

        def before_ask
          Helper.pretty_print :html, doc.to_xhtml
        end

        def validate(input)
          item = doc.css(input)&.first

          return false unless item

          state.store('item', item)

          # TODO: do not show warning about multiple items... but the opposite! show when only one tag is selected
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
