# frozen_string_literal: true

RSpec.describe 'imdb.com/ratings.yml' do
  include_examples 'config.yml', 'imdb.com/ratings.yml', user_id: 'ur7019649'
end
