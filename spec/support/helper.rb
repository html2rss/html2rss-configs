# frozen_string_literal: true

require 'json'
require 'nokogiri'
require 'yaml'
require 'public_suffix'

##
# A collection of helper methods.
module Helper
  ##
  # @param url [String]
  # @return [String, nil]
  def self.url_to_registrable_domain(url)
    host = url_to_host_name(url)
    return host unless host

    registrable_domain(host)
  end

  ##
  # @param url [String]
  # @return [String, nil]
  def self.url_to_host_name(url)
    Html2rss::Url.for_channel(url)&.host
  rescue ArgumentError
    nil
  end

  ##
  # @param host [String]
  # @return [String]
  def self.registrable_domain(host)
    PublicSuffix.domain(host) || host
  rescue PublicSuffix::DomainInvalid
    host
  end

  ##
  # Determines which selectors are referenced in the template of a Html2rss::PostProcessors::Template.
  #
  # @param selectors [Hash<String,Hash>] the 'selectors hash'
  # @return [Array<String>]
  def self.referenced_selectors_in_template(selectors)
    selectors.each_value.flat_map do |selector_hash|
      if selector_hash.is_a?(Hash)
        post_processor_hashes(selector_hash['post_process'], 'template').flat_map do |template|
          string_formatting_references(template['string']).keys
        end
      end
    end
             .compact
  end

  ##
  #
  # @param post_processors [Hash<Hash>, Array<Hash>]
  # @param keep_name [String]
  # @return [Array<Hash>] containing only the hashes stored under the 'keep_name'
  def self.post_processor_hashes(post_processors, keep_name)
    [post_processors].flatten.compact.keep_if { |processor| processor['name'] == keep_name }
  end

  ##
  # Determines the referenced values of "more complex string formatting".
  # return [Hash<String, Class>] the keys with their type
  def self.string_formatting_references(string)
    string.to_s.scan(/%[{<](\w+)[>}](\w)?/).to_h.transform_values do |value|
      case value
      when 'i', 'd', 'u'
        Numeric
      else
        String
      end
    end
  end
end
