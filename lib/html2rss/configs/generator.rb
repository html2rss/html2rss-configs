# frozen_string_literal: true

require 'tty-markdown'
require 'tty-prompt'

require_relative './helper'
require_relative './print_helper'
require_relative 'generator/collector'
require_relative 'generator/file_create_question'
require_relative 'generator/state'

module Html2rss
  module Configs
    ##
    # Namespace for the Feed Config Generator.
    module Generator
      ##
      # Asks the caller questions, using prompt and stores the results in the state.
      # @return [nil]
      def self.start(prompt = TTY::Prompt.new, state = State.new(feed: {}))
        Collector.new(prompt, state).collect

        FileCreateQuestion.new(prompt, state).ask
      end
    end
  end
end
