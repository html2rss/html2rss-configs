# frozen_string_literal: true

RSpec.describe 's3.amaoznaws.com/popular_movies.yml' do
  it_behaves_like 'config.yml', 's3.amazonaws.com/popular_movies.yml'
end
