# frozen_string_literal: true

require_relative './selector_question'

module Html2rss
  module Configs
    module Generator
      ##
      # Asks for the items selector.
      class ItemsSelectorQuestion < SelectorQuestion
        private

        def before_ask
          Helper.pretty_print :html, doc.to_xhtml
        end

        def validate(input)
          item = doc.css(input)&.first

          return false unless item

          state.store('item', item)

          print_tag(input, item, warn_on_multiple: false, warn_on_single: true)

          prompt.yes?("Use selector `#{input}`?")
        end

        def doc
          state.fetch('doc')
        end
      end
    end
  end
end
