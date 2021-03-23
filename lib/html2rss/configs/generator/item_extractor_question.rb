# frozen_string_literal: true

require 'readline'

require_relative './question'
require 'byebug'
module Html2rss
  module Configs
    module Generator
      class ItemExtractorQuestion
        attr_reader :prompt, :state, :options

        def initialize(state, **options)
          @prompt = TTY::Prompt.new
          @state = state
          @options = options
        end

        def ask
          @input = prompt.select('Which extractor would you like to use?', Html2rss::ItemExtractors::NAME_TO_CLASS.keys)

          Generator.print_markdown "`#{Html2rss::ItemExtractors.item_extractor_factory(extractor_options, item).get}`"

          if prompt.yes?("Use extractor '#{@input}'?")
            state.store(options[:path], extractor_configuration) if options[:path]
          else
            ask
          end
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

          # TODO: use prompt.collect ... etc
          missing = missing.map do |miss|
            print_available_attributes if miss == :attribute

            value = Readline.readline("Enter extractor option value for '#{miss}': ", true)

            [miss, value.chomp]
          end

          @extractor_options = missing.to_h || {}
          default_extractor_options.merge(@extractor_options)
        end

        def print_available_attributes
          puts "Available attributes: #{item.css(@selector)&.first&.attributes&.keys&.sort&.join(', ')}"
        end

        def extractor_configuration
          extra_options = {}
          extra_options[:post_process] = :sanitize_html if @extractor == :html

          { extractor: @input }.merge(@extractor_options || {}).merge(extra_options)
        end
      end
    end
  end
end
