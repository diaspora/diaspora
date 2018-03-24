# frozen_string_literal: true

describe JsxcHelper, :type => :helper do
  before do
    AppConfig.chat.server.bosh.port = 1234
    AppConfig.chat.server.bosh.bind = "/bind"
  end

  describe "#get_bosh_endpoint" do
    it "using http scheme and default values" do
      AppConfig.chat.server.bosh.proxy = false
      expect(helper.get_bosh_endpoint).to include %Q(http://localhost:1234/bind)
    end

    it "using https scheme and no port" do
      AppConfig.chat.server.bosh.proxy = true
      allow(AppConfig).to receive(:pod_uri).and_return(Addressable::URI.parse("https://localhost/"))
      expect(helper.get_bosh_endpoint).to include %Q(https://localhost/bind)
    end
  end
end
