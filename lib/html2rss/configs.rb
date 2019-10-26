require 'html2rss/configs/version'
require 'yaml'

module Html2rss
  module Configs
    class Error < StandardError; end
    class ConfigNotFound < Html2rss::Configs::Error; end

    def self.file_names
      @file_names ||= Dir[File.join(__dir__, '**', '*.yml')].map { |name| name }.freeze
    end

    def self.find_by_name(name, params = {})
      raise 'name must be a string' unless name.is_a?(String)
      raise 'name must be in folder/file format' unless name.include?('/')

      name = "#{name}.yml" unless name.end_with?('.yml')

      file_name = file_names.find { |f| f.end_with?(name) }

      raise ConfigNotFound unless file_name

      config = YAML.safe_load(File.open(file_name))
      format_config(config, params).freeze
    end

    def self.format_config(config, params)
      return config if params.keys.none?

      symbol_params = {}
      params.each_pair { |k, v| symbol_params[k.to_sym] = v }

      config['channel'].keys.each do |attribute_name|
        next unless config['channel'][attribute_name]&.is_a?(String)

        config['channel'][attribute_name] = format(config['channel'][attribute_name], symbol_params)
      end

      config
    end
    private_class_method :format_config
  end
end
