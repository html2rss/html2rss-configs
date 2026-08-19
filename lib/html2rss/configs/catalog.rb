# frozen_string_literal: true

require 'uri'
require 'yaml'

require_relative 'catalog_entry'

module Html2rss
  module Configs
    ##
    # Sole owner of embedded catalog serialization from packaged YAML configs.
    module Catalog
      class Error < Html2rss::Error; end
      class MissingDirectoryTitle < Error; end

      module_function

      ##
      # @return [Array<CatalogEntry>] sorted catalog entries
      def entries
        Html2rss::Configs.file_names.sort.filter_map { |file_name| build_entry(file_name) }
      end

      ##
      # @param file_name [String]
      # @return [CatalogEntry]
      def build_entry(file_name)
        config = YAML.safe_load(File.read(file_name), symbolize_names: true)
        directory = config.fetch(:directory, {})
        title = directory[:title]
        raise MissingDirectoryTitle, "Missing directory.title in #{file_name}" if title.to_s.strip.empty?

        id = entry_id(file_name)
        channel = config.fetch(:channel, {})
        parameters_block = config[:parameters]

        CatalogEntry.new(
          id:,
          path: "/#{id}.rss",
          source: 'embedded',
          directory: {
            title: title.to_s,
            summary: directory[:summary],
            topics: Array(directory[:topics])
          }.compact,
          channel: {
            url: channel.fetch(:url),
            language: channel[:language],
            title: channel[:title] || title.to_s
          }.compact,
          parameters: {
            schema: parameter_schema(channel.fetch(:url), parameters_block),
            defaults: default_parameters(parameters_block)
          }
        )
      end

      ##
      # @param file_name [String]
      # @return [String]
      def entry_id(file_name)
        relative = file_name.sub(%r{\A.*/configs/}, '')
        File.join(*relative.split('/')[0..-2], File.basename(relative, '.yml'))
      end

      ##
      # @param parameters [Hash, nil]
      # @return [Hash{String => Object}]
      def default_parameters(parameters)
        return {} unless parameters.is_a?(Hash)

        parameters.each_with_object({}) do |(name, config), defaults|
          next unless config.is_a?(Hash) && config.key?(:default)

          defaults[name.to_s] = config[:default]
        end
      end

      ##
      # @param channel_url [String]
      # @param parameters [Hash, nil]
      # @return [Hash{String => Object}]
      def parameter_schema(channel_url, parameters)
        schema = url_parameter_types(channel_url)
        return schema unless parameters.is_a?(Hash)

        parameters.each do |name, config|
          next unless config.is_a?(Hash)

          schema[name.to_s] = config.slice(:type).transform_keys(&:to_s)
        end
        schema
      end

      ##
      # @param url [String]
      # @return [Hash{String => String}]
      def url_parameter_types(url)
        url.to_s.scan(/%[{<](\w+)[>}](\w)?/).each_with_object({}) do |(name, format), types|
          types[name] = { 'type' => numeric_format?(format) ? 'integer' : 'string' }
        end
      end

      ##
      # @param format [String, nil]
      # @return [Boolean]
      def numeric_format?(format)
        %w[i d u].include?(format)
      end
    end
  end
end
