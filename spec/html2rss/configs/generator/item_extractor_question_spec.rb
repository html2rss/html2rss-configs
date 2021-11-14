# frozen_string_literal: true

require 'html2rss/configs/generator/item_extractor_question'

RSpec.describe Html2rss::Configs::Generator::ItemExtractorQuestion do
  describe '.choices' do
    subject { described_class.choices }

    specify(:aggregate_failures) do
      is_expected.to be_a(Array)
      is_expected.to include(:text)
    end
  end
end
