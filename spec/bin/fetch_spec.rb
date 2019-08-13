RSpec.describe 'bin/fetch' do
  let(:executable) { 'bin/fetch' }

  let(:name) { 'spiegel.de/impressum_autor' }

  context 'with one argument' do
    subject { `#{executable} #{name} id=14051` }

    it { is_expected.to start_with '<?xml version="1.0" encoding="UTF-8"?>' }
    it { is_expected.to include '<link>https://www.spiegel.de/impressum/autor-14051.html</link>' }
  end
end
