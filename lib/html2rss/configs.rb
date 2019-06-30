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

    def self.find_by_name(name, params = {})
      raise 'must give a name as string' unless name.is_a?(String)

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

      %w[url title language].each do |attribute_name|
        next unless config['channel'][attribute_name]

        config['channel'][attribute_name] = format(config['channel'][attribute_name], symbol_params)
      end

      config
    end
    private_class_method :format_config
  end
end
