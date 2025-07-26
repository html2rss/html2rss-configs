# frozen_string_literal: true

RSpec.describe 'blog.mondediplo.net/feed.yml' do
  it_behaves_like 'config.yml', 'blog.mondediplo.net/feed.yml', blog: '-Defense-en-ligne-'
end
