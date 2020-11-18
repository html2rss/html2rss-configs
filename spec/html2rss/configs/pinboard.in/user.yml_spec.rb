# frozen_string_literal: true

RSpec.describe 'pinboard.in/user.yml' do
  include_examples 'config.yml', 'pinboard.in/user.yml', username: :marcin
end
