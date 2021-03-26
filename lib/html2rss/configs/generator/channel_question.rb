# frozen_string_literal: true

require 'faraday'
require 'nokogiri'

require_relative './question'

module Html2rss
  module Configs
    module Generator
      ##
      # Asks the required RSS channel options and tries to determine some.
      class ChannelQuestion < Question
        def self.validate(url, state, _prompt, **_options)
          uri = URI(url)
          return false unless uri.absolute?

          response = Faraday.new(url: uri, headers: {}).get

          if response.success?
            state.store(state.class::HTML_DOC_PATH, Helper.strip_down_html(response.body))
            return true
          end

          Helper.handle_unsuccessful_http_response(response.status, response.headers)
          false
        end

        private

        def before_ask
          Helper.print_markdown <<~MARKDOWN
            # html2rss config generator

            This wizard will help you create a new *feed config*.

            You can quit at any time by pressing `Ctrl`+`C`.


          MARKDOWN
        end

        def process(url)
          { url: url, language: doc.css('html').first['lang'], ttl: 360, time_zone: 'UTC' }
            .keep_if { |_key, value| value.to_s != '' }
        end

        def doc
          state.fetch(state.class::HTML_DOC_PATH)
        end
      end
    end
  end
end
