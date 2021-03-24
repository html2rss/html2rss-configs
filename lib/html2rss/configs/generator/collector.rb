# frozen_string_literal: true

require_relative './channel_question'
require_relative './items_selector_question'
require_relative './selector_question'
require_relative './state'

module Html2rss
  module Configs
    module Generator
      class Collector
        def initialize(prompt, state)
          @state = state
          @prompt = prompt
        end

        def collect
          [
            ChannelQuestion.new(prompt, state, path: 'feed.channel', question: 'Please enter the URL to scrape:', prompt_options: { default: 'https://gil.desmarais.de/blog' }),
            ItemsSelectorQuestion.new(prompt, state, path: 'feed.selectors.items', question: 'Items selector:', prompt_options: { default: 'article' }),
            SelectorQuestion.new(prompt, state, path: 'feed.selectors.title', question: "Item's Title selector:", prompt_options: { default: 'main > a:first' }),
            SelectorQuestion.new(prompt, state, path: 'feed.selectors.link', question: "Item's URL selector:", prompt_options: { default: 'main > a:first' }),
            SelectorQuestion.new(prompt, state, path: 'feed.selectors.description', question: "Item's description selector:", prompt_options: { default: '.p-summary' })
          ].each(&:ask)
        end

        private

        attr_reader :state, :prompt
      end
    end
  end
end
