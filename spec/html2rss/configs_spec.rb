# frozen_string_literal: true

RSpec.describe Html2rss::Configs do
  it 'has a version number' do
    expect(Html2rss::Configs::VERSION).not_to be nil
  end

  describe '.file_names' do
    subject { described_class.file_names }

    specify(:aggregate_failures) do
      is_expected.to be_an Array
      is_expected.to be_frozen
    end
  end

  describe '.find_by_name' do
    context 'with valid name' do
      subject { described_class.find_by_name('tagesspiegel.de/mostread') }

      specify(:aggregate_failures) do
        is_expected.to be_a Hash
        is_expected.to be_frozen
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
