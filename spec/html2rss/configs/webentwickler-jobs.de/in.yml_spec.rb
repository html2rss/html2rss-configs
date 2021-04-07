# frozen_string_literal: true

RSpec.describe 'webentwickler-jobs.de/in.yml' do
  include_examples 'config.yml', 'webentwickler-jobs.de/in.yml', region: 'berlin'
end
