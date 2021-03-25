# frozen_string_literal: true

module Html2rss
  module Configs
    module Generator
      class FilesAndPaths
        attr_reader :config_name, :config_dir

        def initialize(config_name, config_dir)
          raise 'config_name is required' if config_name.to_s == ''
          raise 'config_dir is required' if config_dir.to_s == ''

          @config_name = config_name
          @config_dir = config_dir
        end

        ##
        # @return [String]
        def self.gem_root
          File.expand_path(File.join(__dir__, '../../../..'))
        end

        ##
        # @return [String]
        def yml_dir
          File.join(self.class.gem_root, 'lib/html2rss/configs/', config_dir)
        end

        ##
        # @return [String]
        def spec_dir
          File.join(self.class.gem_root, 'spec/html2rss/configs', config_dir)
        end

        ##
        # @return [String]
        def spec_file
          File.join(spec_dir, "#{config_name}.yml_spec.rb")
        end

        ##
        # @return [String]
        def yml_file
          File.join(yml_dir, "#{config_name}.yml")
        end

        ##
        # @return [String]
        def rspec_yml_file_path
          "#{[config_dir, config_name].join('/')}.yml"
        end

        ##
        # @return [String]
        def relative_yml_path
          yml_file.gsub(self.class.gem_root, '')[1..-1]
        end

        ##
        # @return [String]
        def relative_spec_path
          spec_file.gsub(self.class.gem_root, '')[1..-1]
        end
      end
    end
  end
end
