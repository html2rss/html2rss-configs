# frozen_string_literal: true

require_relative './question'
require_relative './item_extractor_question'

module Html2rss
  module Configs
    module Generator
      ##
      # A generic base class for asking a selector and lastly invokes
      # `ItemExtractorQuestion` to build a full *selector hash*.
      class SelectorQuestion < Question
        def self.validate(input:, state:, prompt:, options:)
          tag = state.fetch(state.class::ITEM_PATH).css(input) or return false

          Helper.print_tag(input, tag)

          extractor_question = ItemExtractorQuestion.new(prompt, state, options.merge(selector: input))
          extractor_question.ask

          path = options[:path]

          print_config(state, path)
          prompt.yes?("Use this selector hash for #{path}?")
        end

        def self.print_config(state, path)
          config = state.fetch(path).dup

          Helper.print_markdown <<~MARKDOWN

            **Selector hash:**

            ```yaml
            #{Helper.to_simple_yaml(config).gsub("---\n", '').chomp}
            ```
          MARKDOWN
        end

        private

        def before_ask
          Helper.pretty_print :html, item.to_xhtml
        end

        def process(input)
          { selector: input }
        end
      end
    end
  end
end
