# frozen_string_literal: true

RSpec.describe FetchReport do
  subject(:report) { described_class.new(results, failing_since:, today:) }

  let(:today) { Date.new(2026, 12, 7) }
  let(:failing_since) { {} }
  let(:results) { [passed('a.org/news.yml')] }

  def result(file_name, status, problems: [], newest: Time.utc(2026, 12, 1), warnings: [])
    FetchCheck::Result.new(file_name:, status:, item_count: 3, problems:, newest_published_at: newest,
                           quality_warnings: warnings)
  end

  def passed(file_name, **) = result(file_name, :passed, **)
  def failed(file_name) = result(file_name, :failed, problems: ['Extracted 0 items (minimum required: 3)'])

  context 'when every config passes' do
    it 'is clear' do
      expect(report).not_to be_actionable
    end

    it 'summarises the sweep' do
      expect(report.to_markdown).to start_with('Checked 1 configs: 1 passed, 0 failed, 0 blocked, 0 skipped.')
    end
  end

  context 'when a config fails for the first time' do
    let(:results) { [failed('b.org/news.yml')] }

    it 'starts its clock today', :aggregate_failures do
      expect(report).to be_actionable
      expect(report.to_markdown).to include(
        '- `b.org/news.yml` since 2026-12-07: Extracted 0 items (minimum required: 3)',
        '<!-- fetch-report-state {"failing_since":{"b.org/news.yml":"2026-12-07"}} -->'
      )
    end
  end

  context 'when a config has failed for 13 weeks' do
    let(:results) { [failed('b.org/news.yml')] }
    let(:failing_since) { { 'b.org/news.yml' => today - 91 } }

    it 'is due for removal' do
      expect(report.to_markdown).to include("## Due for removal (1)\n\n", '- `b.org/news.yml` since 2026-09-07')
    end
  end

  context 'when a failing config passes again' do
    let(:failing_since) { { 'a.org/news.yml' => today - 30 } }

    it 'drops it from the state' do
      expect(report.to_markdown).to end_with('<!-- fetch-report-state {"failing_since":{}} -->')
    end
  end

  context 'when the newest item is older than 6 months' do
    let(:results) do
      [passed('c.org/news.yml', newest: Time.utc(2026, 1, 1)), passed('d.org/news.yml', newest: Time.utc(2025, 10, 1))]
    end

    it 'is stale, and due for removal after 12 months', :aggregate_failures do
      expect(report).to be_actionable
      expect(report.to_markdown).to include('- `c.org/news.yml` newest item 2026-01-01',
                                            '- `d.org/news.yml` newest item 2025-10-01 (due for removal)')
    end
  end

  context 'when a config has no dates' do
    let(:results) { [passed('e.org/news.yml', newest: nil)] }

    it 'is never stale' do
      expect(report).not_to be_actionable
    end
  end

  context 'when a site blocks the runner' do
    let(:results) { [result('f.org/news.yml', :blocked)] }

    it 'lists it without counting it', :aggregate_failures do
      expect(report).not_to be_actionable
      expect(report.to_markdown).to include("## Blocked on CI (1)\n").and end_with('{"failing_since":{}} -->')
    end
  end

  context 'with html2rss quality warnings' do
    let(:results) { [passed('g.org/news.yml', warnings: %w[short_titles])] }

    it 'reports them without acting' do
      expect(report.to_markdown).to include('- `g.org/news.yml`: short_titles')
    end
  end

  context 'with only an enhance no-op warning' do
    let(:results) { [passed('g.org/news.yml', warnings: %w[enhance_no_op])] }

    it 'leaves the warnings section out' do
      expect(report.to_markdown).not_to include('Quality warnings')
    end
  end

  describe '.failing_since_from' do
    it 'reads the first failing days from the last report' do
      body = "text\n<!-- fetch-report-state {\"failing_since\":{\"b.org/news.yml\":\"2026-11-30\"}} -->"

      expect(described_class.failing_since_from(body)).to eq('b.org/news.yml' => Date.new(2026, 11, 30))
    end

    it 'starts fresh without a previous report' do
      expect(described_class.failing_since_from(nil)).to eq({})
    end

    it 'starts fresh when the state comment was edited into invalid JSON' do
      expect(described_class.failing_since_from('<!-- fetch-report-state {"failing_since": -->')).to eq({})
    end
  end
end
