# frozen_string_literal: true

require 'readline'

module Html2rss
  module Configs
    module Generator
      ##
      # Asks a questions and stores the answer as a string in the state under the path.
      class Question
        attr_reader :state, :path, :question, :answer

        def initialize(state, **options)
          @options = options
          @path = options[:path]
          @question = options[:question]
          @state = state
        end

        # rubocop:disable Metrics/MethodLength
        def ask
          done = false

          before_ask
          while !done && (input = Readline.readline("#{question}: ", true))
            if validate(input)
              processed = process(input)

              state.store(path, processed) if path

              done = true
            else
              validation_failed(input)
            end
          end
        end
        # rubocop:enable Metrics/MethodLength

        private

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
          puts "#{question} [Y/n]"
          inchar = $stdin.getch

          puts inchar

          inchar.chomp == '' || inchar.casecmp('y').zero?
        end
      end
    end
  end
end
