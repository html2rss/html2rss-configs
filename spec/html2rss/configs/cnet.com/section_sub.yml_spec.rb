# frozen_string_literal: true

RSpec.describe 'cnet.com/section_sub.yml' do
  it_behaves_like 'config.yml', 'cnet.com/section_sub.yml', section: 'culture', sub: 'internet'
end
