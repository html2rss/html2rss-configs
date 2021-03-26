# frozen_string_literal: true

require 'html2rss'

module Html2rss
  module Configs
    module Generator
      ##
      # Asks which item extractor to use.
      # When an extractor requires additional arguments, it asks for those, too.
      class ItemExtractorQuestion
        attr_reader :prompt, :state, :options

        def initialize(prompt, state, **options)
          @prompt = prompt
          @state = state
          @options = options
        end

        def ask
          self.extractor_name = prompt.select('Which extractor would you like to use?',
                                              self.class.choices, filter: true)

          full_extractor_options = extractor_options
          print_extractor_result(full_extractor_options)

          prompt.yes?("Use extractor '#{extractor_name}'?") ? state.store(path, full_extractor_options) : ask
        end

        ##
        # @return [Array<Symbol>] the available extractor names, with default extractor at index 0
        def self.choices(default = Html2rss::ItemExtractors::DEFAULT_NAME)
          [default].concat(Html2rss::ItemExtractors::NAME_TO_CLASS.keys - [default])
        end

        def print_extractor_result(extractor_options)
          extractor_result = Html2rss::ItemExtractors.item_extractor_factory(
            extractor_options.merge(channel: { url: state.fetch('feed.channel.url') }),
            item
          )
                                                     .get

          Helper.print_markdown "`#{extractor_result}`"
        end

        private

        attr_accessor :extractor_name

        def item
          state.fetch(state.class::ITEM_PATH)
        end

        def path
          @options[:path]
        end

        def extractor_default?
          extractor_name == Html2rss::ItemExtractors::DEFAULT_NAME
        end

        def extractor_html?
          extractor_name == :html
        end

        def selector_config
          { selector: options[:selector] }
        end

        def extractor_options
          options = {}
          options = ask_for_missing_options if missing_extractor_option_names.any?

          selector_config.merge(extractor_configuration, options)
        end

        def extractor_configuration
          options = {}
          options[:extractor] = extractor_name unless extractor_default?

          extra_options = {}
          extra_options[:post_process] = [{ name: :sanitize_html }] if extractor_html?

          options.merge(extra_options)
        end

        def missing_extractor_option_names
          # :channel is added to the options when fetching
          Html2rss::ItemExtractors.options_class(extractor_name).members - selector_config.keys - [:channel]
        end

        def ask_for_missing_options
          missing_extractor_option_names.to_a.map do |miss|
            value = if miss == :attribute
                      prompt.select('Select the attribute', available_attributes, filter: true)
                    else
                      prompt.ask("Extractor option #{miss} value:", required: true)
                    end

            [miss, value.chomp]
          end.to_h
        end

        def available_attributes
          item.css(options[:selector])&.first&.attributes&.keys&.sort&.to_a
        end
      end
    end
  end
end
