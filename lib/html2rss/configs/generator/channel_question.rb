# frozen_string_literal: true

require 'faraday'

require_relative './question'

module Html2rss
  module Configs
    module Generator
      ##
      # Asks the required RSS channel options and tries to determine some.
      class ChannelQuestion < Question
        def self.validate(input:, state:, **_opts)
          uri = URI(input)
          return false unless uri.absolute?

          # TODO: In the validation, there should be no data storing.
          # TODO: This should use the same request method as h2r gem
          response = Faraday.new(url: uri, headers: {}).get

          if response.success?
            handle_success_response(state, body: response.body, headers: response.headers)
          else
            Helper.handle_unsuccessful_http_response(response.status, response.headers)
            false
          end
        end

        def self.handle_success_response(state, body:, headers:)
          json = headers['content-type'].include?('application/json')

          if json
            state.store('feed.channel.json', json)
            body = Html2rss::Utils.object_to_xml(JSON.parse(body))
          end

          state.store(state.class::HTML_DOC_PATH, Helper.strip_down_html(body))

          true
        end

        private

        def before_ask
          PrintHelper.markdown <<~MARKDOWN
            # html2rss config generator

            This wizard will help you create a new *feed config*.

            You can quit at any time by pressing `Ctrl`+`C`.


          MARKDOWN
        end

        def process(url)
          language = doc.css('html').first['lang']
          { url: url, language: language, ttl: 360, time_zone: 'UTC' }
            .keep_if { |_key, value| value.to_s != '' }
        end

        def doc
          state.fetch(state.class::HTML_DOC_PATH)
        end
      end
    end
  end
end
