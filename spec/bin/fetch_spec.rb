RSpec.describe 'bin/fetch' do
  let(:executable) { 'bin/fetch' }

  let(:name) { 'github.com/nuxt.js_releases' }

  context 'with one argument' do
    subject { `#{executable} #{name}` }

    it { is_expected.to start_with '<?xml version="1.0" encoding="UTF-8"?>' }
    it { is_expected.to include '<link>https://github.com/nuxt/nuxt.js/releases/tag/' }
  end
end
