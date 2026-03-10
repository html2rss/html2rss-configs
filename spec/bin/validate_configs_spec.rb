# frozen_string_literal: true

require 'fileutils'
require 'stringio'
require 'tmpdir'

RSpec.describe 'bin/validate_configs' do
  let(:script_path) { File.expand_path('../../bin/validate_configs', __dir__) }

  it 'passes validation for parameterized configs when defaults are present' do
    config = <<~YAML
      parameters:
        query:
          type: string
          default: ruby
      headers:
        X-Query: "%<query>s"
      channel:
        url: "https://example.com/search?q=%<query>s"
      selectors:
        items:
          selector: ".item"
        title:
          selector: "h2"
    YAML

    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'lib', 'html2rss', 'configs', 'example.com'))
      File.write(File.join(dir, 'lib', 'html2rss', 'configs', 'example.com', 'search.yml'), config)

      stdout = StringIO.new
      stderr = StringIO.new
      original_stdout = $stdout
      original_stderr = $stderr
      $stdout = stdout
      $stderr = stderr

      Dir.chdir(dir) { load script_path }

      expect(stdout.string).to include('ok   lib/html2rss/configs/example.com/search.yml')
      expect(stdout.string).to include('1 configs validated successfully.')
      expect(stderr.string).to be_empty
    ensure
      $stdout = original_stdout
      $stderr = original_stderr
    end
  end
end
