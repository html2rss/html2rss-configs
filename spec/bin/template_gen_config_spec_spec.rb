# frozen_string_literal: true

RSpec.describe 'bin/template_gen_config_spec' do
  let(:executable) { 'bin/template_gen_config_spec' }

  let(:file_name) { 'foo/bar.yml' }

  context 'with one argument' do
    subject { `#{executable} #{file_name}` }

    it { is_expected.to start_with "RSpec.describe '#{file_name}' do" }
    it { is_expected.to include "  include_examples 'config.yml', '#{file_name}'" }
  end
end
