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
          puts 'html2rss config generator'
          puts
          puts 'This wizard will help you create a feed config.'
          puts
          puts 'You can quit at any time by pressing Ctrl+C.'
        end

        def validate(url)
          @response = Faraday.new(url: URI(url), headers: {}).get
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
