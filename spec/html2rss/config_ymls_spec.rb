Html2rss::Configs.file_names.each do |file_name|
  RSpec.describe file_name do
    include_examples 'config.yml', file_name
  end
end
