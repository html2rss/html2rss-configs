# frozen_string_literal: true

require 'yaml'
require 'active_support/core_ext/hash'

require_relative './channel_question'
require_relative './items_selector_question'
require_relative './selector_question'

module Html2rss
  module Configs
    module Generator
      class Questionnaire
        def questions
          @questions ||= [
            ChannelQuestion.new(self, path: 'channel', question: 'Please enter the URL to scrape'),
            ItemsSelectorQuestion.new(self, path: 'selectors.items', question: 'Items selector'),
            SelectorQuestion.new(self, path: 'selectors.title', question: "Item's Title selector"),
            SelectorQuestion.new(self, path: 'selectors.link', question: "Item's URL selector")
          ]
        end

        def ask_questions
          questions.each(&:ask)
        end

        def store(path, value, store = :feed)
          case (splits = path.split('.')).size
          when 1
            config[store][path] = value
          when 2
            first, second = splits
            config[store][first] ||= {}
            config[store][first][second] = value
          else
            raise "Path #{path} is nested too deep. Must be max 2 levels deep"
          end
        end

        def fetch(path, store = :meta)
          case (splits = path.split('.')).size
          when 1
            config[store].fetch(path)
          when 2
            first, second = splits
            config[store][first].fetch(second)
          else
            raise "Path #{path} is nested too deep. Must be max 2 levels deep"
          end
        end

        def to_yaml
          YAML.dump(feed_config)
        end

        def channel_url
          feed_config.dig('channel', 'url')
        end

        private

        def feed_config
          config[:feed].deep_stringify_keys
        end

        def config
          @config ||= { feed: {}, meta: {} }
        end
      end
    end
  end
end
