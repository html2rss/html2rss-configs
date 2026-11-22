# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'tmpdir'

RSpec.describe 'registry bundle' do
  let(:repo_root) { File.expand_path('..', __dir__) }

  def build_bundle(output_path)
    env = { 'BUNDLE_GEMFILE' => File.join(repo_root, 'tool/Gemfile') }
    stdout, stderr, status = Open3.capture3(
      env,
      File.join(repo_root, 'tool/registry-build'),
      '--output',
      output_path,
      chdir: repo_root
    )
    expect(status).to eq(0), [stdout, stderr].join
  end

  def load_bundle(output_path)
    extract_dir = File.join(File.dirname(output_path), 'extracted')
    FileUtils.mkdir_p(extract_dir)
    File.open(output_path, 'rb') { |io| Html2rss::Registry::Archive.extract!(io, into: extract_dir) }
    Html2rss::Registry::Bundle.load(extract_dir, trust: :integrity_only)
  end

  it 'builds a tarball' do
    Dir.mktmpdir do |tmpdir|
      output = File.join(tmpdir, 'registry-bundle.tar.gz')
      build_bundle(output)
      expect(File).to be_file(output)
    end
  end

  it 'loads manifest and sorted catalog entries', :aggregate_failures do
    Dir.mktmpdir do |tmpdir|
      output = File.join(tmpdir, 'registry-bundle.tar.gz')
      build_bundle(output)
      bundle = load_bundle(output)

      expect(bundle.manifest.registry_id).to eq('official')
      expect(bundle.catalog_entries).not_to be_empty
      expect(bundle.catalog_entries.map(&:id)).to eq(bundle.catalog_entries.map(&:id).sort)
    end
  end

  it 'maps anthropic.com/news catalog metadata', :aggregate_failures do
    Dir.mktmpdir do |tmpdir|
      bundle = load_bundle(build_and_return(File.join(tmpdir, 'registry-bundle.tar.gz')))

      anthropic = bundle.catalog_entries.find { |entry| entry.id == 'anthropic.com/news' }
      expect(anthropic).to have_attributes(id: 'anthropic.com/news', path: '/anthropic.com/news.rss')
      expect(anthropic.directory[:title]).to eq('Anthropic — News')
      expect(anthropic.channel[:title]).to eq('Anthropic — News')
      expect(anthropic.parameters).to eq(schema: {}, defaults: {})
    end
  end

  it 'extracts cnet parameter schema and defaults', :aggregate_failures do
    Dir.mktmpdir do |tmpdir|
      bundle = load_bundle(build_and_return(File.join(tmpdir, 'registry-bundle.tar.gz')))

      cnet = bundle.catalog_entries.find { |entry| entry.id == 'cnet.com/section_sub' }
      expect(cnet.parameters[:defaults]).to eq('section' => 'tech')
      expect(cnet.parameters[:schema]['section']).to eq('type' => 'string')
    end
  end

  def build_and_return(output_path)
    build_bundle(output_path)
    output_path
  end
end
