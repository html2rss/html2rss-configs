# frozen_string_literal: true

require 'html2rss/configs/generator/question'
require 'html2rss/configs/generator/state'
require 'tty-prompt'

RSpec.describe Html2rss::Configs::Generator::Question do
  describe '#ask' do
    let(:prompt) { instance_double(TTY::Prompt) }
    let(:state) { instance_double(Html2rss::Configs::Generator::State) }
    let(:options) { { path: 'spec.path', question: 'Path?' } }

    before do
      allow(prompt).to receive(:ask).and_return 'something'
      allow(state).to receive(:store)
    end

    it 'asks and stores in the store under path', :aggregate_failures do
      described_class.new(prompt, state, options).ask
      expect(prompt).to have_received :ask
      expect(state).to have_received(:store).with(options[:path], 'something')
    end
  end
end
