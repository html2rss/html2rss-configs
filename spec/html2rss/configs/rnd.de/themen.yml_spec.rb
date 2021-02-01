# frozen_string_literal: true

RSpec.describe 'rnd.de/themen.yml' do
  include_examples 'config.yml', 'rnd.de/themen.yml', thema: 'hamburg'
end
