# frozen_string_literal: true

require_relative './channel_question'
require_relative './items_selector_question'
require_relative './selector_question'
require_relative './state'

module Html2rss
  module Configs
    module Generator
      # TODO: rename to FeedConfig or StepController or something
      class Questionnaire
        def initialize
          @state = State.new(feed: {})
          @prompt = TTY::Prompt.new
        end

        def questions
          @questions ||= [
            ChannelQuestion.new(prompt, state, path: 'feed.channel', question: 'Please enter the URL to scrape:'),
            ItemsSelectorQuestion.new(prompt, state, path: 'feed.selectors.items', question: 'Items selector:'),
            SelectorQuestion.new(prompt, state, path: 'feed.selectors.title', question: "Item's Title selector:"),
            SelectorQuestion.new(prompt, state, path: 'feed.selectors.link', question: "Item's URL selector:"),
            SelectorQuestion.new(prompt, state, path: 'feed.selectors.description', question: "Item's description selector:")
          ]
        end

        def ask_questions
          questions.each(&:ask)
        end

        def to_yaml
          Helper.simple_yaml(state.fetch('feed'))
        end

        def channel_url
          state.fetch 'feed.channel.url'
        end

        private

        attr_reader :state, :prompt
      end
    end
  end
end
