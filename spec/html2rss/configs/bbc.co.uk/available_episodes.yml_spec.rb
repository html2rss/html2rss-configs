# frozen_string_literal: true

RSpec.describe 'bbc.co.uk/available-episodes.yml' do
  it_behaves_like 'config.yml', 'bbc.co.uk/available_episodes.yml', id: 'b006wkfp'
end
