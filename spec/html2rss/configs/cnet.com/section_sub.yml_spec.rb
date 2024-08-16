# frozen_string_literal: true

RSpec.describe 'cnet.com/section_sub.yml' do
  include_examples 'config.yml', 'cnet.com/section_sub.yml', section: 'culture', sub: 'internet'
end
