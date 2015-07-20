require 'spec_helper'

describe JsxcHelper, :type => :helper do
  before do
    AppConfig.chat.server.bosh.proxy = false
    AppConfig.chat.server.bosh.port = 1234
    AppConfig.chat.server.bosh.bind = '/bind'
    AppConfig.environment.url = "https://localhost/"
  end

  describe "#get_bosh_endpoint" do
    it "using http scheme and default values" do
      expect(helper.get_bosh_endpoint).to include %Q(http://localhost:1234/bind)
    end

    it "using https scheme and no port" do
      AppConfig.chat.server.bosh.proxy = true
      expect(helper.get_bosh_endpoint).to include %Q(https://localhost/bind)
    end
  end
end
