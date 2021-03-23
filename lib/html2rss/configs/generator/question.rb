# frozen_string_literal: true

require 'readline'
require 'tty-prompt'

module Html2rss
  module Configs
    module Generator
      ##
      # Asks a questions and stores the answer as a string in the state under the path.
      class Question
        attr_reader :state, :path, :question, :answer, :prompt_options, :prompt

        def initialize(state, **options)
          @prompt = TTY::Prompt.new
          @options = options
          @path = options[:path]
          @question = options[:question]
          @prompt_options = options[:prompt_options] || { required: true }
          @state = state
        end

        def ask
          before_ask
          validated_input = prompt.ask(question, prompt_options) do |q|
            q.validate ->(input) { validate(input) }
          end

          processed_input = process(validated_input)
          state.store(path, processed_input) if path
        end

        private

        # rename to print banner or print instructions
        def before_ask; end

        def validation_failed(input); end

        def item
          state.fetch('item')
        end

        protected

        def validate(input)
          input.to_s != ''
        end

        def process(input)
          input
        end

        def ask_yes_no_with_yes_default(question)
          prompt.yes?(question)
        end
      end
    end
  end
end
