require 'html2rss/configs/version'
require 'yaml'

module Html2rss
  module Configs
    class Error < StandardError; end
    class ConfigNotFound < Html2rss::Configs::Error; end

    PREFIX = File.join('lib', 'html2rss', 'configs').freeze

    def self.file_names
      @file_names ||= Dir[File.join(PREFIX, '**', '*.yml')].map do |name|
        name.gsub(PREFIX, '')[1..-1]
      end.sort.freeze
    end

    def self.find_by_name(name)
      raise 'must give a name as string' unless name.is_a?(String)

      name = "#{name}.yml" unless name.end_with?('.yml')

      file_name = file_names.bsearch { |f| f == name }

      raise ConfigNotFound unless file_name

      YAML.safe_load(File.open(File.join(PREFIX, file_name))).freeze
    end
  end
end
