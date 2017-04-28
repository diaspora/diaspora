#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Rack::InternetExplorerVersion do
  before :all do
    @app = Rack::Builder.parse_file(Rails.root.join("config.ru").to_s).first
  end

  subject { get_response_for_user_agent(@app, ua_string) }

  context "non-IE browser" do
    let(:ua_string) { "another browser chromeframe" }

    it "shouldn't complain about the browser" do
      expect(subject.body).not_to match(/Diaspora doesn't support your version of Internet Explorer/)
    end
  end

  context "new IE" do
    let(:ua_string) { "MSIE 9" }

    it "shouldn't complain about the browser" do
      expect(subject.body).not_to match(/Diaspora doesn't support your version of Internet Explorer/)
    end
  end

  context "old IE" do
    let(:ua_string) { "MSIE 7" }

    it "should complain about the browser" do
      expect(subject.body).to match(/Diaspora doesn't support your version of Internet Explorer/)
    end

    it "should have the correct content-length header" do
      expect(subject.headers["Content-Length"]).to eq(subject.body.length.to_s)
    end
  end

  context "Specific case with no space after MSIE" do
    let(:ua_string) { "Mozilla/4.0 (compatible; MSIE8.0; Windows NT 6.0) .NET CLR 2.0.50727" }

    it "should complain about the browser" do
      expect(subject.body).to match(/Diaspora doesn't support your version of Internet Explorer/)
    end
  end
end
