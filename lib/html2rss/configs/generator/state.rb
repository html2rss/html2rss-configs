# frozen_string_literal: true

require 'hashie'

module Html2rss
  module Configs
    module Generator
      ##
      # Provides a flexible data store. It's roughly inspired by Vuex/Redux.
      class State
        FEED_PATH = 'feed'
        HTML_DOC_PATH = 'doc'
        ITEM_PATH = 'item'

        class Storage < Hash
          include Hashie::Extensions::MergeInitializer
          include Hashie::Extensions::IndifferentAccess
          include Hashie::Extensions::DeepMerge
        end

        def initialize(initial_state = {})
          @state = Storage.new(initial_state || {})
        end

        ##
        # Stores the value under path.
        #
        # @param path [String] consists of multiple keys, joined with a dot, e.g. 'a.path.to.somewhere'
        # @param value [Object]
        def store(path, value)
          splits = path.to_s.split('.')

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

        ##
        # This is a Hash which automatically creates values (hashes) on access.
        # It allows e.g. `hash[:a][:b][:c][:d] = 'something'`.
        # @return [Hash]
        def hash
          @hash ||= Hash.new { |hash, key| hash[key] = hash.dup.clear }
        end

        attr_reader :state
      end
    end
  end
end
