# frozen_string_literal: true

require 'active_support/core_ext/hash'

module Html2rss
  module Configs
    module Generator
      ##
      # Provides a flexible data store. It's roughly inspired by Vuex/Redux.
      class State
        def initialize(initial_state = {})
          @state = (initial_state || {}).with_indifferent_access
        end

        ##
        # Stores the value under path.
        #
        # @param path [String] consists of multiple keys, joined with a dot, e.g. 'a.path.to.somewhere'
        # @param value [Object]
        # rubocop:disable Metrics/MethodLength
        def store(path, value)
          splits = path.to_s.split('.')

          # This is a Hash which automatically creates values (hashes) on access.
          # It allows e.g. `new_hash[:a][:b][:c][:d] = 'something'`.
          hash = Hash.new { |h, k| h[k] = h.dup.clear }

          # Now, traverse down the given path. `node` acts as our reference.
          node = hash
          splits.each_with_index do |key, index|
            # Traverse further 'down' (or to the right, however you like it),
            # until we've found the place where to assign value to.

            if index < splits.size - 1
              node = node[key]
            else
              node[key] = value
            end
          end

          # Finally, deep merge the new hash into our state.
          state.deep_merge!(hash)
        end
        # rubocop:enable Metrics/MethodLength

        ##
        # Returns the previously stored value at path.
        # @param path [String]
        # @return [Object, Hash]
        # @raise [KeyError] if no value is stored under path
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
