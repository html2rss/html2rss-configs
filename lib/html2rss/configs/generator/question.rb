# frozen_string_literal: true

module Html2rss
  module Configs
    module Generator
      ##
      # Asks a questions and stores the answer as a string under the path in the state.
      class Question
        attr_reader :state, :prompt_options, :prompt

        def initialize(prompt, state, **options)
          @prompt = prompt
          @state = state
          @options = options

          @prompt_options = options[:prompt_options] || { required: true }
        end

        def ask
          before_ask
          validated_input = prompt.ask(question, prompt_options) do |answer|
            answer.validate ->(input) { self.class.validate(input, state, prompt, @options) }
          end

          processed_input = process(validated_input)
          state.store(path, processed_input) if path
        end

        def self.validate(input, _state, _prompt, **_options)
          input.to_s != ''
        end

        private

        def process(input)
          input
        end

        def before_ask; end

        def item
          state.fetch(state.class::ITEM_PATH)
        end

        def path
          @options[:path]
        end

        def question
          @options[:question]
        end
      end
    end
  end
end
