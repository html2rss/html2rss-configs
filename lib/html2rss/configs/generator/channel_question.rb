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
          @response.success?
        end

        def process(url)
          state.store('doc', doc)

          value = { url: url, language: doc.css('html').first['lang'], ttl: 360, time_zone: 'UTC' }

          value.keep_if { |_k, v| v.to_s != '' }
        end

        def doc
          return @doc if defined?(@doc)

          # Make the beautification more beautiful:
          # force line breaks after/before angle brackets.
          messy_html = @response.body
          messy_html.gsub!('<', "\n<")
          messy_html.gsub!('>', ">\n")

          doc = Nokogiri.HTML(messy_html, &:noblanks)

          # remove nodes without innerText
          doc.xpath('//text()').each { |t| t.remove if t.to_s.strip == '' }
          # remove empty nodes
          doc.search(':empty').remove
          @doc = doc
        end
      end
    end
  end
end
