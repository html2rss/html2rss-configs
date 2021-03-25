# frozen_string_literal: true

require 'html2rss/configs/generator/files_and_paths'

RSpec.describe Html2rss::Configs::Generator::FilesAndPaths do
  describe '.gem_root' do
    it do
      expect(described_class.gem_root).to eq File.expand_path(File.join(__dir__, '../../../..'))
    end
  end

  context 'with mocked .gem_root' do
    gem_root = '/tmp/h2rc-mock'

    before { allow(described_class).to receive(:gem_root).and_return gem_root }

    let(:instance) { described_class.new('whatever', 'domainname.tld') }

    {
      spec_dir: "#{gem_root}/spec/html2rss/configs/domainname.tld",
      spec_file: "#{gem_root}/spec/html2rss/configs/domainname.tld/whatever.yml_spec.rb",
      relative_spec_path: 'spec/html2rss/configs/domainname.tld/whatever.yml_spec.rb',

      yml_dir: "#{gem_root}/lib/html2rss/configs/domainname.tld",
      yml_file: "#{gem_root}/lib/html2rss/configs/domainname.tld/whatever.yml",
      relative_yml_path: 'lib/html2rss/configs/domainname.tld/whatever.yml',

      rspec_yml_file_path: 'domainname.tld/whatever.yml'
    }.each_pair do |method_name, expect|
      describe "##{method_name}" do
        it { expect(instance.public_send(method_name)).to eq expect }
      end
    end
  end
end
