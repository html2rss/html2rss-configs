# frozen_string_literal: true

require 'tty-markdown'
require 'tty-prompt'

require_relative 'generator/collector'
require_relative 'generator/file_creator'
require_relative './helper'

module Html2rss
  module Configs
    module Generator
      def self.start(prompt = TTY::Prompt.new, state = State.new(feed: {}))
        Collector.new(prompt, state).collect

        feed_config = state.fetch('feed')

        Helper.print_markdown <<~MARKDOWN
          ## This is your feed config

          ```yaml
          #{Helper.to_simple_yaml(feed_config)}
          ```
        MARKDOWN

        create = prompt.yes?('Would you like to create a file alongside a spec for this feed config?')
        FileCreator.new(prompt, feed_config).create if create

        # TODO: print a thanks & good bye note
        #    with urls where to ask for help etc or more instructions to submit
        #    to h2rc.
        # https://github.com/piotrmurach/tty-link
      end
    end
  end
end
