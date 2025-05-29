# frozen_string_literal: true

RSpec.describe Html2rss::Configs do
  it 'has a version number' do
    expect(Html2rss::Configs::VERSION).not_to be_nil
  end

  describe '.file_names' do
    subject(:file_names) { described_class.file_names }

    specify(:aggregate_failures) do
      expect(file_names).to be_an(Array) & be_frozen
    end
  end

  describe '.find_by_name' do
    context 'with valid name' do
      subject(:find_by_name) { described_class.find_by_name('adfc.de/pressemitteilungen') }

      specify(:aggregate_failures) do
        expect(find_by_name).to be_a(Hash) & be_frozen
      end
    end

    context 'with name not being a String' do
      it 'raises ConfigNotFound error' do
        expect { described_class.find_by_name(:foobar) }.to raise_error(RuntimeError)
      end
    end

    context 'with name not not containing a folder' do
      it 'raises ConfigNotFound error' do
        expect { described_class.find_by_name('foobar') }.to raise_error(RuntimeError)
      end
    end

    context 'with inexistent config' do
      it 'raises ConfigNotFound error' do
        expect { described_class.find_by_name('foobar/baz') }.to raise_error(
          Html2rss::Configs::ConfigNotFound
        )
      end
    end
  end
end
