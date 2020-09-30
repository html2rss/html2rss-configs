# frozen_string_literal: true

RSpec.describe 'bin/fetch' do
  subject { `#{executable} #{name}` }

  let(:executable) { 'bin/fetch' }
  let(:name) { 'stackoverflow.com/hot_network_questions' }

  it { is_expected.to start_with '<?xml version="1.0" encoding="UTF-8"?>' }
  it { is_expected.to include '<link>https://stackoverflow.com/questions</link>' }
end
