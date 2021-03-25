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
        private

        def before_ask
          Helper.pretty_print :html, item.to_xhtml
        end

        def validate(input)
          tag = item.css(input)

          return false unless tag

          print_tag(input, tag)

          extractor_question = ItemExtractorQuestion.new(prompt, state, path: path, selector: input)
          extractor_question.ask
          print_config(input, extractor_question)

          prompt.yes?("Use this selector hash for #{path}?")
        end

        def print_config(input, extractor_question)
          config = state.fetch(path).dup.merge(selector: input)

          Helper.print_markdown <<~MARKDOWN

            **Selector hash:**

            ```yaml
            #{Helper.to_simple_yaml(config).gsub("---\n", '').chomp}
            ```

            **The resulting value is:**
          MARKDOWN

          extractor_question.print_extractor_result
        end

        def process(input)
          { selector: input }
        end

        def print_tag(input, tag, warn_on_multiple: true, warn_on_single: false)
          if warn_on_multiple && tag.count > 1
            Helper.print_markdown <<~MARKDOWN
              ***
              `#{input}` selects multiple elements!
              Please write a selector as precise as possible to select just one element.
              ***
            MARKDOWN
          elsif warn_on_single && tag.count == 1
            Helper.print_markdown <<~MARKDOWN
              ***
              `#{input}` selects just one element!
              Please broaden the selector to select multiple elements.
              ***
            MARKDOWN
          end

          Helper.print_markdown "**The selector `#{input}` selects:**"
          Helper.pretty_print :html, tag&.to_xhtml
        end
      end
    end
  end
end
