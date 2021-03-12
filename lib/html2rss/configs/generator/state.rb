# frozen_string_literal: true

require 'active_support/core_ext/hash'

module Html2rss
  module Configs
    module Generator
      class State
        def initialize(initial_state = {})
          @state = (initial_state || {}).with_indifferent_access
        end

        # TODO: refactor to support arbitrary path levels
        def store(path, value)
          case (splits = path.to_s.split('.')).size
          when 1
            state[splits[0]] = value
          when 2
            first, second = splits
            state[first] ||= {}
            state[first][second] = value
          when 3
            state[splits[0]] ||= {}
            state[splits[0]][splits[1]] ||= {}
            state[splits[0]][splits[1]][splits[2]] = value
          else
            raise "Path #{path} is nested too deep. Must be max 3 levels deep"
          end
        end

        def fetch(path)
          case (splits = path.to_s.split('.')).size
          when 1
            state.fetch(splits[0])
          else
            (state.dig(*splits[0..-2]) || {}).fetch(splits[-1])
          end
        end

        private

        attr_reader :state
      end
    end
  end
end
