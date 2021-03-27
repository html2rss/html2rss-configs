# frozen_string_literal: true

require 'html2rss/configs/generator/channel_question'

RSpec.describe Html2rss::Configs::Generator::ChannelQuestion do
  it { expect(described_class).to be < Html2rss::Configs::Generator::Question }
end
