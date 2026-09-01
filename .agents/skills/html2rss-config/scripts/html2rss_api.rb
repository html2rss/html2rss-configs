# frozen_string_literal: true

# Shared html2rss gem facades (same verbs as MCP/CLI).
# Usage: require_relative 'html2rss_api' from skill scripts.

require 'bundler/setup'
require 'digest'
require 'fileutils'
require 'uri'
require 'yaml'
require 'html2rss'

module Html2rssConfigApi
  module_function

  def recon(url, cache_dir: nil, **)
    Html2rss.recon(url, cache_dir:, **)
  end

  def capture(url, **)
    Html2rss.capture(url, **)
  end

  def test_config(path, **)
    Html2rss.test(path, **)
  end

  def apply_config_hash(config)
    Html2rss.apply(config)
  end

  def recon_html_cache_path(url, cache_dir)
    host = URI(url.to_s).host.to_s.delete_prefix('www.')
    host = 'snapshot' if host.empty?
    digest = Digest::SHA256.hexdigest(url.to_s)[0, 12]
    File.join(cache_dir, "#{host}-#{digest}.html")
  end

  def copy_recon_cache_to_slug(url, cache_dir, slug)
    src = recon_html_cache_path(url, cache_dir)
    dest = File.join(cache_dir, "#{slug}.html")
    FileUtils.cp(src, dest) if File.file?(src)
    File.file?(dest) ? dest : src
  end

  def inject_registry_id(yaml_content, registry_id)
    doc = YAML.safe_load(yaml_content, permitted_classes: [Symbol], symbolize_names: true)
    doc[:registry] = { id: registry_id }
    modeline, = yaml_content.lines.first&.match(%r{\A(# yaml-language-server:.*)\n}i)
    body = Html2rss::Config.to_yaml(doc.transform_keys(&:to_sym))
    modeline ? "#{modeline}\n#{body}" : body
  end

  def registry_id_for(domain, slug)
    "#{domain}/#{slug.sub(/\.yml\z/, '')}"
  end
end
