# frozen_string_literal: true

require 'readline'
require 'html2rss'

require_relative './question'
require 'byebug'

module Html2rss
  module Configs
    module Generator
      class ItemExtractorQuestion
        attr_reader :prompt, :state, :options

        def initialize(prompt, state, **options)
          @prompt = prompt
          @state = state
          @options = options
        end

        def ask
          @input = prompt.select('Which extractor would you like to use?', self.class.choices, filter: true)

          print_extractor_result

          if prompt.yes?("Use extractor '#{@input}'?")
            state.store(options[:path], extractor_configuration) if options[:path]
          else
            ask
          end
        end

        ##
        # @return Array<Symbol> the available extractor names, with default extractor at index 0
        def self.choices(default = Html2rss::ItemExtractors::DEFAULT_NAME)
          names = Html2rss::ItemExtractors::NAME_TO_CLASS.keys
          names -= [default]
          names.prepend default
          names
        end

        private

        def item
          state.fetch('item')
        end

        def default_extractor_options
          { extractor: @input, selector: options[:selector], channel: { url: state.fetch('feed.channel.url') } }
        end

        def extractor_options
          missing = Html2rss::ItemExtractors.options_class(@input).members - default_extractor_options.keys

          return default_extractor_options if missing.none?

          @extractor_options = ask_for_missing_options(missing)
          default_extractor_options.merge(@extractor_options)
        end

        def available_attributes
          item.css(options[:selector])&.first&.attributes&.keys&.sort&.to_a
        end

        def ask_for_missing_options(missing)
          missing.to_a.map do |miss|
            value = if miss == :attribute
                      prompt.select('Select attribute with desired value', available_attributes, filter: true)
                    else
                      prompt.ask("Extractor option #{miss} value:", required: true)
                    end

            [miss, value.chomp]
          end.to_h
        end

        def print_extractor_result
          Helper.print_markdown "`#{Html2rss::ItemExtractors.item_extractor_factory(extractor_options, item).get}`"
        end

        def extractor_configuration
          extra_options = {}
          extra_options[:post_process] = :sanitize_html if @input == :html

          { extractor: @input }.merge(@extractor_options || {}).merge(extra_options)
        end
      end
    end
  end
end
