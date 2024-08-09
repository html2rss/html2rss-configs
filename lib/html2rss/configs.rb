# frozen_string_literal: true

require 'html2rss/configs/version'
require 'yaml'

module Html2rss
  ##
  # The namespace for this gem
  module Configs
    class Error < Html2rss::Error; end
    class ConfigNotFound < Html2rss::Configs::Error; end

    ##
    # @return [Array<String>]
    def self.file_names
      @file_names ||= Dir[File.join(__dir__, '**', '*.yml')].freeze
    end

    ##
    # @param name [String] the name of the config to find. format: `domainname/name`
    # @return [Hash<Symbol, Object>] the hash to create a Html2rss::Config
    def self.find_by_name(name)
      raise 'name must be a string' unless name.is_a?(String)
      raise 'name must be in folder/file format' unless name.include?('/')

      name = "#{name}.yml" unless name.end_with?('.yml')

      file_name = file_names.find { |f| f.end_with?(name) }

      raise ConfigNotFound unless file_name

      YAML.safe_load(File.open(file_name), symbolize_names: true).freeze
    end
  end
end
