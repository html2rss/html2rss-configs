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

        # rubocop:disable Metrics/MethodLength
        def collect
          [
            ChannelQuestion.new(prompt, state, path: 'feed.channel',
                                               question: 'Please enter the URL to scrape:', prompt_options: {}),
            ItemsSelectorQuestion.new(prompt, state, path: 'feed.selectors.items',
                                                     question: 'Items selector:',
                                                     prompt_options: { default: 'article' }),
            SelectorQuestion.new(prompt, state, path: 'feed.selectors.title',
                                                question: "Item's Title selector:",
                                                prompt_options: { default: '[itemprop=headline]' }),
            SelectorQuestion.new(prompt, state, path: 'feed.selectors.link',
                                                question: "Item's URL selector:",
                                                prompt_options: { default: 'a:first' }),
            SelectorQuestion.new(prompt, state, path: 'feed.selectors.description',
                                                question: "Item's description selector:",
                                                prompt_options: { default: '[itemprop=description]' })
          ].each(&:ask)
        end
        # rubocop:enable Metrics/MethodLength

        private

        attr_reader :state, :prompt
      end
    end
  end
end
