# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'tmpdir'

RSpec.describe 'registry bundle' do
  let(:repo_root) { File.expand_path('..', __dir__) }

  it 'builds and loads with integrity-only trust', :aggregate_failures do
    Dir.mktmpdir do |tmpdir|
      output = File.join(tmpdir, 'registry-bundle.tar.gz')
      env = { 'BUNDLE_GEMFILE' => File.join(repo_root, 'tool/Gemfile') }
      stdout, stderr, status = Open3.capture3(env, File.join(repo_root, 'tool/registry-build'), '--output', output,
                                              chdir: repo_root)
      expect(status).to eq(0), [stdout, stderr].join

      extract_dir = File.join(tmpdir, 'extracted')
      FileUtils.mkdir_p(extract_dir)
      File.open(output, 'rb') { |io| Html2rss::Registry::Archive.extract!(io, into: extract_dir) }

      bundle = Html2rss::Registry::Bundle.load(extract_dir, trust: :integrity_only)

      expect(bundle.manifest.registry_id).to eq('official')
      expect(bundle.catalog_entries).not_to be_empty
      expect(bundle.catalog_entries.map(&:id)).to eq(bundle.catalog_entries.map(&:id).sort)

      anthropic = bundle.catalog_entries.find { |entry| entry.id == 'anthropic.com/news' }
      expect(anthropic).to have_attributes(
        id: 'anthropic.com/news',
        path: '/anthropic.com/news.rss'
      )
      expect(anthropic.directory[:title]).to eq('Anthropic — News')
      expect(anthropic.channel[:title]).to eq('Anthropic — News')
      expect(anthropic.parameters).to eq(schema: {}, defaults: {})

      cnet = bundle.catalog_entries.find { |entry| entry.id == 'cnet.com/section_sub' }
      expect(cnet.parameters[:defaults]).to eq('section' => 'tech')
      expect(cnet.parameters[:schema]['section']).to eq('type' => 'string')
    end
  end
end
