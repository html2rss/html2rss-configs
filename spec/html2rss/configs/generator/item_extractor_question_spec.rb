# frozen_string_literal: true

require 'html2rss/configs/generator/item_extractor_question'

RSpec.describe Html2rss::Configs::Generator::ItemExtractorQuestion do
  describe '.choices' do
    subject { described_class.choices }

    it { is_expected.to be_a(Array) }
    it { is_expected.to include(:text) }
  end
end
