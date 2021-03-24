# frozen_string_literal: true

require 'html2rss/configs/generator/items_selector_question'

RSpec.describe Html2rss::Configs::Generator::ItemsSelectorQuestion do
  it { expect(described_class).to be < Html2rss::Configs::Generator::SelectorQuestion }
end
