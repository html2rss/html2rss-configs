# frozen_string_literal: true

module Html2rss
  module Configs
    ##
    # Value object for a single embedded catalog entry exposed to consumers.
    CatalogEntry = Data.define(
      :id,
      :path,
      :source,
      :directory,
      :channel,
      :parameters
    ) do
      ##
      # Serializes the entry to the catalog wire shape v1.
      #
      # @return [Hash{Symbol => Object}]
      def to_h
        {
          id:,
          path:,
          source:,
          directory:,
          channel:,
          parameters:
        }
      end
    end
  end
end
