require 'html2rss/configs/version'
require 'yaml'

module Html2rss
  module Configs
    class Error < StandardError; end
    class ConfigNotFound < Html2rss::Configs::Error; end

    def self.file_names
      @file_names ||= Dir[File.join(__dir__, '**', '*.yml')].map do |name|
        name
      end.freeze
    end

    def self.find_by_name(name)
      raise 'must give a name as string' unless name.is_a?(String)

      name = "#{name}.yml" unless name.end_with?('.yml')

      file_name = file_names.find { |f| f.end_with?(name) }

      raise ConfigNotFound unless file_name

      YAML.safe_load(File.open(file_name)).freeze
    end
  end
end
