# frozen_string_literal: true

require 'date'
require 'json'

##
# Turns one sweep of FetchCheck results into the weekly issue body.
#
# The issue carries its own state: each failing config's first failing day
# sits in a hidden comment, so the next sweep can tell how long it has been
# broken. Removal stays a human PR; the report only says what is due.
class FetchReport
  REMOVAL_AFTER_DAYS = 13 * 7
  STALE_AFTER_DAYS = 183
  STALE_REMOVAL_AFTER_DAYS = 365
  # Only says enhance would change nothing, which configs with enhance: false expect.
  IGNORED_WARNINGS = %w[enhance_no_op].freeze
  STATE_MARKER = /<!-- fetch-report-state (?<json>\{.*?\}) -->/m

  ##
  # @param previous_body [String, nil] last week's issue body
  # @return [Hash{String => Date}] failing config => first failing day
  def self.failing_since_from(previous_body)
    json = previous_body.to_s[STATE_MARKER, :json]
    return {} unless json

    JSON.parse(json).fetch('failing_since', {}).transform_values { |day| Date.iso8601(day) }
  rescue JSON::ParserError, Date::Error
    {}
  end

  ##
  # @param results [Array<FetchCheck::Result>]
  # @param failing_since [Hash{String => Date}]
  # @param today [Date]
  def initialize(results, failing_since:, today:)
    @results = results.sort_by(&:file_name)
    @today = today
    @failing_since = failing(@results).to_h do |result|
      [result.file_name, failing_since.fetch(result.file_name, today)]
    end
  end

  # @return [Boolean] whether a config is failing or has stopped publishing
  def actionable? = failing(@results).any? || stale.any?

  # @return [String] Markdown issue body, ending in the state comment
  def to_markdown
    [
      summary,
      section('Due for removal', due_lines, 'Failing for 13 weeks or more. Repair or remove each by PR.'),
      section('Failing', failing_lines, 'Counted toward removal from the date shown.'),
      section('Stale', stale_lines, 'No item newer than 6 months. Remove after 12 months without a new item.'),
      section('Blocked on CI', blocked_lines, 'The site refused the runner. Not counted; check locally each quarter.'),
      section('Quality warnings', warning_lines, 'Reported by html2rss; not failures.'),
      state_comment
    ].compact.join("\n\n")
  end

  private

  def failing(results) = results.select { |result| result.status == :failed }

  def days_failing(result) = (@today - @failing_since.fetch(result.file_name)).to_i

  def stale
    @results.select do |result|
      result.status == :passed && result.newest_published_at &&
        (@today - result.newest_published_at.to_date).to_i > STALE_AFTER_DAYS
    end
  end

  def summary
    counts = @results.group_by(&:status).transform_values(&:size)
    tally = %i[passed failed blocked skipped].map { |status| "#{counts.fetch(status, 0)} #{status}" }
    "Checked #{@results.size} configs: #{tally.join(', ')}."
  end

  def section(title, lines, note)
    return if lines.empty?

    "## #{title} (#{lines.size})\n\n#{note}\n\n#{lines.join("\n")}"
  end

  def due_lines
    failing(@results).select { |result| days_failing(result) >= REMOVAL_AFTER_DAYS }
                     .map { |result| "- `#{result.file_name}` since #{@failing_since.fetch(result.file_name)}" }
  end

  def failing_lines
    failing(@results).reject { |result| days_failing(result) >= REMOVAL_AFTER_DAYS }.map do |result|
      "- `#{result.file_name}` since #{@failing_since.fetch(result.file_name)}: #{result.problems.join('; ')}"
    end
  end

  def stale_lines
    stale.map do |result|
      newest = result.newest_published_at.to_date
      due = (@today - newest).to_i > STALE_REMOVAL_AFTER_DAYS ? ' (due for removal)' : ''
      "- `#{result.file_name}` newest item #{newest}#{due}"
    end
  end

  def blocked_lines = @results.select { |result| result.status == :blocked }.map { |result| "- `#{result.file_name}`" }

  def warning_lines
    @results.filter_map do |result|
      warnings = result.quality_warnings - IGNORED_WARNINGS
      "- `#{result.file_name}`: #{warnings.join(', ')}" if result.status == :passed && warnings.any?
    end
  end

  def state_comment
    state = { failing_since: @failing_since.transform_values(&:iso8601) }
    "<!-- fetch-report-state #{JSON.generate(state)} -->"
  end
end
