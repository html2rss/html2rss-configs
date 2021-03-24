# frozen_string_literal: true

require 'html2rss/configs/generator/selector_question'

RSpec.describe Html2rss::Configs::Generator::SelectorQuestion do
  it { expect(described_class).to be < Html2rss::Configs::Generator::Question }
end
