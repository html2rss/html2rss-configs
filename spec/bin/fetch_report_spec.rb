# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

RSpec.describe 'bin/fetch_report' do # rubocop:disable RSpec/DescribeClass
  let(:script_path) { File.expand_path('../../bin/fetch_report', __dir__) }
  let(:dir) { Dir.mktmpdir }
  let(:out) { File.join(dir, 'report.md') }
  let(:failing_file) { 'kcl.ac.uk/news.yml' }

  before do
    allow(FetchCheck).to receive(:call) do |file_name|
      status = file_name == failing_file ? :failed : :passed
      FetchCheck::Result.new(file_name:, status:, item_count: 3, problems: [], newest_published_at: nil,
                             quality_warnings: [])
    end
  end

  after { FileUtils.rm_rf(dir) }

  def run_script(*args)
    stub_const('ARGV', args)
    load script_path
  end

  it 'checks every config and reports the failing one as actionable', :aggregate_failures do
    expect { run_script('--out', out, '--jobs', '2') }.to output("actionable\n").to_stdout
    expect(FetchCheck).to have_received(:call).exactly(Html2rss::Configs.file_names.size).times
    expect(File.read(out)).to include("## Failing (1)\n", "`#{failing_file}` since #{Date.today}")
  end

  it 'carries the first failing day forward from --previous', :aggregate_failures do
    previous = File.join(dir, 'previous.md')
    File.write(previous, %(<!-- fetch-report-state {"failing_since":{"#{failing_file}":"2026-01-05"}} -->))

    expect { run_script('--out', out, '--previous', previous) }.to output("actionable\n").to_stdout
    expect(File.read(out)).to include("`#{failing_file}` since 2026-01-05")
  end
end
