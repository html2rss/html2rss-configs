# frozen_string_literal: true

require 'html2rss/configs/generator/state'

RSpec.describe Html2rss::Configs::Generator::State do
  subject(:instance) { described_class.new('key' => { 'subkey' => :a }) }

  describe '.store' do
    it do
      expect { instance.store('key.subkey', []) }
        .to change { instance.fetch('key.subkey') }
        .from(:a)
        .to([])
    end

    it 'merges into existing values' do
      instance.store('key.another', 'e')
      expect(instance.fetch('key')).to eq('another' => 'e', 'subkey' => :a)
    end
  end

  describe '.fetch' do
    context 'with unknown path' do
      it { expect { instance.fetch('unknown.path') }.to raise_error KeyError }
    end

    context 'with known path' do
      it { expect(instance.fetch('key.subkey')).to eq :a }
    end
  end
end
