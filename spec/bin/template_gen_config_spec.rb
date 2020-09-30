# frozen_string_literal: true

RSpec.describe 'bin/template_gen_config' do
  let(:executable) { 'bin/template_gen_config' }

  let(:domain) { 'foo' }
  let(:name) { 'bar' }

  context 'with two arguments' do
    subject { `#{executable} #{domain} #{name}` }

    it { is_expected.to start_with 'channel:' }
    it { is_expected.to include "url: https://#{domain}/#{name}" }
  end
end
