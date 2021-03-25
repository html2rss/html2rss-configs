# frozen_string_literal: true

require 'faraday'
require 'nokogiri'

require_relative './question'

module Html2rss
  module Configs
    module Generator
      ##
      # Asks the required RSS channel options.
      class ChannelQuestion < Question
        private

        def before_ask
          Helper.print_markdown <<~MARKDOWN
            # html2rss config generator

            This wizard will help you create a new *feed config*.

            You can quit at any time by pressing `Ctrl`+`C`.


          MARKDOWN
        end

        def validate(url)
          uri = URI(url)
          return false unless uri.absolute?

          @response = Faraday.new(url: uri, headers: {}).get
          return true if @response.success?

          handle_unsuccessful_response
        end

        def handle_unsuccessful_response
          case @response.status
          when 300..399
            Helper.print_markdown "The url redirects. Try to use `#{@response.headers['location']}`"
          when 400..599
            # client/server error
            Helper.print_markdown <<~MARKDOWN
              Encountered error **`#{@response.status}`**.
              Here are the response headers which could help debugging:

              ```yaml
              #{Helper.to_simple_yaml(@response.headers).gsub("---\n", '').chomp}
              ```
            MARKDOWN
          end

          false
        end

        def process(url)
          state.store('doc', doc)

          value = { url: url, language: doc.css('html').first['lang'], ttl: 360, time_zone: 'UTC' }

          value.keep_if { |_k, v| v.to_s != '' }
        end

        def doc
          @doc ||= Helper.strip_down_html(@response.body)
        end
      end
    end
  end
end
