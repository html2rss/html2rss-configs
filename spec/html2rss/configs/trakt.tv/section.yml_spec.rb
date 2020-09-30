# frozen_string_literal: true

RSpec.describe 'trakt.tv/section.yml' do
  include_examples 'config.yml', 'trakt.tv/section.yml', section: 'movies', filter: 'trending'
end
