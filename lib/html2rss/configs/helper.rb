# frozen_string_literal: true

module Html2rss
  module Configs
    module Helper
      def self.url_to_directory_name(url)
        URI(url.split('/')[0..2].join('/')).host.gsub(/^(api|www)\./, '')
      end

      def self.url_to_file_name(url)
        path = begin
          URI(url).path
        rescue URI::InvalidURIError
          url.split('/')[3..-1].join('_')
        end

        (['', '/'].include?(path) ? 'index' : path[1..-1]).tr('.~/:<>|%*[]()!@#$', '_')
      end
    end
  end
end
