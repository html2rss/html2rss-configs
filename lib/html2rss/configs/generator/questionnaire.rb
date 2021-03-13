# frozen_string_literal: true

require 'yaml'
require 'json'

require_relative './channel_question'
require_relative './items_selector_question'
require_relative './selector_question'
require_relative './state'

module Html2rss
  module Configs
    module Generator
      # TODO: rename to FeedConfig
      class Questionnaire
        def initialize
          @state = State.new(feed: {})
        end

        def questions
          @questions ||= [
            ChannelQuestion.new(state, path: 'feed.channel', question: 'Please enter the URL to scrape'),
            ItemsSelectorQuestion.new(state, path: 'feed.selectors.items', question: 'Items selector'),
            SelectorQuestion.new(state, path: 'feed.selectors.title', question: "Item's Title selector"),
            SelectorQuestion.new(state, path: 'feed.selectors.link', question: "Item's URL selector")
          ]
        end

        def ask_questions
          questions.each(&:ask)
        end

        def to_yaml
          # To get rid of yaml class annotations regarding HashWithIndifferentAccess,
          # watch this poor dump/parse/dump approach:
          YAML.dump JSON.parse(JSON.generate(state.fetch('feed')))
        end

        def channel_url
          state.fetch 'feed.channel.url'
        end

        private

        attr_reader :state
      end
    end
  end
end
