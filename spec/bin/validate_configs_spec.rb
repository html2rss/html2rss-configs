# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

RSpec.describe 'bin/validate_configs' do # rubocop:disable RSpec/DescribeClass
  let(:script_path) { File.expand_path('../../bin/validate_configs', __dir__) }
  let(:config_path) { File.join('lib', 'html2rss', 'configs', 'example.com', 'search.yml') }
  let(:success_output) do
    a_string_including(
      "ok   #{config_path}",
      '1 configs validated successfully.'
    )
  end

  it 'passes validation for parameterized configs when defaults are present' do
    with_temp_config do |dir|
      expect { run_script(dir) }.to output(success_output).to_stdout
                                                          .and output('').to_stderr
    end
  end

  def with_temp_config
    Dir.mktmpdir do |dir|
      write_config(dir)
      yield dir
    end
  end

  def write_config(dir)
    FileUtils.mkdir_p(File.join(dir, File.dirname(config_path)))
    File.write(File.join(dir, config_path), valid_config)
  end

  def run_script(dir)
    Dir.chdir(dir) { load script_path }
  end

  def valid_config
    <<~YAML
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
  end
end
