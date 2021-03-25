# frozen_string_literal: true

require 'faraday'
require 'nokogiri'

require_relative './question'

module Html2rss
  module Configs
    module Generator
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

          # TODO: print info if response is unsuccessful. in case of redirect, show Location

          @response.success?
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
