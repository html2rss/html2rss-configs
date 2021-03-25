# frozen_string_literal: true

module Html2rss
  module Configs
    module Generator
      ##
      # Asks a questions and stores the answer as a string under the path in the state.
      class Question
        attr_reader :state, :path, :question, :answer, :prompt_options, :prompt

        def initialize(prompt, state, **options)
          @prompt = prompt
          @state = state
          @options = options

          @path = options[:path]
          @question = options[:question]
          @prompt_options = options[:prompt_options] || { required: true }
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

        def validate(input)
          input.to_s != ''
        end

        def process(input)
          input
        end

        def before_ask; end

        def item
          state.fetch('item')
        end
      end
    end
  end
end
