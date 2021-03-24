# frozen_string_literal: true

require 'html2rss/configs/version'
require 'yaml'

module Html2rss
  module Configs
    class Error < StandardError; end

    class ConfigNotFound < Html2rss::Configs::Error; end

    def self.file_names
      @file_names ||= Dir[File.join(__dir__, '**', '*.yml')].freeze
    end

    def self.find_by_name(name)
      raise 'name must be a string' unless name.is_a?(String)
      raise 'name must be in folder/file format' unless name.include?('/')

      name = "#{name}.yml" unless name.end_with?('.yml')

      file_name = file_names.find { |f| f.end_with?(name) }

      raise ConfigNotFound unless file_name

      YAML.safe_load(File.open(file_name)).freeze
    end
  end
end
