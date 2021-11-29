# frozen_string_literal: true

RSpec.describe 'apnews.com/hub.yml' do
  include_examples 'config.yml', 'apnews.com/hub.yml', section: 'world-news'
end
