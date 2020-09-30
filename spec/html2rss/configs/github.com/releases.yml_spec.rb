# frozen_string_literal: true

RSpec.describe 'github.com/releases.yml' do
  include_examples 'config.yml', 'github.com/releases.yml', username: 'nuxt', repository: 'nuxt.js'
end
