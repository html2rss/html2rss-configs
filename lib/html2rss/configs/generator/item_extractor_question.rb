# frozen_string_literal: true

require 'readline'

require_relative './question'

module Html2rss
  module Configs
    module Generator
      class ItemExtractorQuestion < Question
        def initialize(state, **options)
          super
          @question = "Choose [1..#{extractors.size}]"
          @selector = options[:selector]
        end

        private

        def before_ask
          puts "\nWhich extractor would you like to use?"
          extractors.each_with_index do |extractor, index|
            @default_index = index if extractor == Html2rss::ItemExtractors::DEFAULT_NAME

            puts ["#{index + 1})", extractor, @default_index == index ? '(default)' : ''].join(' ')
          end
        end

        def validate(index)
          index = ['0', ''].include?(index.to_s) ? @default_index : (index.to_i - 1).abs
          @extractor = extractors[index]

          puts Html2rss::ItemExtractors.item_extractor_factory(extractor_options, item).get

          true
        end

        def extractors
          @extractors ||= Html2rss::ItemExtractors::NAME_TO_CLASS.keys
        end

        def default_extractor_options
          { extractor: @extractor, selector: @selector, channel: { url: state.fetch('feed.channel.url') } }
        end

        def extractor_options
          missing = Html2rss::ItemExtractors.options_class(@extractor).members - default_extractor_options.keys

          return default_extractor_options if missing.none?

          missing = missing.map do |miss|
            print_available_attributes if miss == :attribute

            value = Readline.readline("Enter extractor option value for '#{miss}': ", true)

            [miss, value.chomp]
          end

          @extractor_options = missing.to_h || {}
          default_extractor_options.merge(@extractor_options)
        end

        def print_available_attributes
          puts "Available attributes: #{item.css(@selector)&.first&.attributes&.keys&.join(', ')}"
        end

        def process(_index)
          return {} if Html2rss::ItemExtractors::DEFAULT_NAME == @extractor

          extra_options = {}
          extra_options[:post_process] = :sanitize_html if @extractor == :html

          { extractor: @extractor }.merge(@extractor_options || {}).merge(extra_options)
        end
      end
    end
  end
end
