# frozen_string_literal: true

RSpec.describe Html2rss::Configs::PrintHelper do
  describe '.code(lang, code)' do
    let(:messy_html) do
      <<~HTML
        <!DOCTYPE html>
        <html><head><title>Can't make something up</title></head><body>
          <p>Foo goes into a bar and... buz</p>
          <div><span></span></div>
          <script type="text/javascript">alert('lol');</script>
        </body></html>
      HTML
    end

    let(:output) { StringIO.new }

    it do
      expect { described_class.code(:html, messy_html, output: output) }
        .to change(output, :string)
        .from('')
        .to(/Foo goes into a bar and... buz/)
    end
  end
end
