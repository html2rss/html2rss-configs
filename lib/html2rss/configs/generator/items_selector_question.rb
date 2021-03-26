# frozen_string_literal: true

require_relative './selector_question'

module Html2rss
  module Configs
    module Generator
      ##
      # Asks for the items selector.
      class ItemsSelectorQuestion < SelectorQuestion
        STATE_PATH_ITEM = 'item'

        def self.validate(input:, state:, prompt:, **_)
          selector = input
          item = state.fetch(state.class::HTML_DOC_PATH).css(selector)&.first or return false

          state.store(state.class::ITEM_PATH, item)

          Helper.print_tag(selector, item, warn_on_multiple: false, warn_on_single: true)

          prompt.yes?("Use selector `#{selector}`?")
        end

        private

        def before_ask
          Helper.pretty_print :html, doc.to_xhtml
        end

        def doc
          state.fetch(state.class::HTML_DOC_PATH)
        end
      end
    end
  end
end
