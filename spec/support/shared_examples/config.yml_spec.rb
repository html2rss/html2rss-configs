RSpec.shared_examples 'config.yml' do |file_name|
  subject(:yaml) { YAML.safe_load(file) }

  let(:file) { File.open(file_name) }

  it 'is parseable' do
    expect { yaml }.not_to raise_error
  end

  it 'resides in topfolder named after channel.url\'s host' do
    dirname = File.dirname(file.path).split(File::Separator).last
    host_name = URI(yaml['channel']['url']).host.gsub('www.', '')

    expect(dirname).to eq(host_name)
  end

  it 'has channel' do
    expect(yaml).to have_key 'channel'
  end

  context 'with channel present' do
    %w[title url ttl].each do |required_attribute|
      it "has channel.#{required_attribute}" do
        expect(yaml['channel']).to have_key required_attribute
      end
    end
  end

  it 'has selectors' do
    expect(yaml).to have_key 'selectors'
  end

  context 'with selectors present' do
    it { expect(yaml['selectors']).to have_key 'items' }

    %w[items title].each do |required_attribute|
      it "has selectors.#{required_attribute}" do
        expect(yaml['selectors'][required_attribute]).not_to be_empty
      end
    end
  end
end
