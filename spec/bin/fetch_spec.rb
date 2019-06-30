RSpec.describe 'bin/fetch' do
  let(:executable) { 'bin/fetch' }

  let(:name) { 'bbc.com/mostread' }

  context 'with one argument' do
    subject { `#{executable} #{name}` }

    it { is_expected.to start_with '<?xml version="1.0" encoding="UTF-8"?>' }
    it { is_expected.to include '<link>https://www.bbc.com/news/popular/read</link>' }
  end
end
