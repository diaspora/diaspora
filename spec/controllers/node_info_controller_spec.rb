describe NodeInfoController do
  describe "#jrd" do
    it "responds to JSON" do
      get :jrd, format: :json

      expect(response).to be_success
    end

    it "returns a JRD" do
      expect(NodeInfo).to receive(:jrd).with(include("%{version}")).and_call_original

      get :jrd, format: :json

      jrd = JSON.parse(response.body)
      expect(jrd).to include "links" => [{
        "rel"  => "http://nodeinfo.diaspora.software/ns/schema/1.0",
        "href" => node_info_url("1.0")
      }, {
        "rel"  => "http://nodeinfo.diaspora.software/ns/schema/2.0",
        "href" => node_info_url("2.0")
      }]
    end
  end

  describe "#document" do
    context "invalid version" do
      it "responds with not found" do
        get :document, version: "0.0", format: :json

        expect(response.code).to eq "404"
      end
    end

    %w(1.0 2.0).each do |version|
      context "version #{version}" do
        it "responds to JSON" do
          get :document, version: version, format: :json

          expect(response).to be_success
        end

        it "calls NodeInfoPresenter" do
          expect(NodeInfoPresenter).to receive(:new).with(version)
            .and_return(double(as_json: {}, content_type: "application/json"))

          get :document, version: version, format: :json
        end

        it "notes the schema in the content type" do
          get :document, version: version, format: :json

          expect(response.content_type)
            .to eq("application/json; profile=http://nodeinfo.diaspora.software/ns/schema/#{version}#")
        end
      end
    end
  end

  describe "#statistics" do
    it "responds to format json" do
      get :statistics, format: "json"
      expect(response.code).to eq("200")
    end

    it "contains json" do
      get :statistics, format: "json"
      json = JSON.parse(response.body)
      expect(json["name"]).to be_present
    end

    it "responds to html" do
      get :statistics, format: "html"
      expect(response.code).to eq("200")
    end

    it "responds to mobile" do
      get :statistics, format: "mobile"
      expect(response.code).to eq("200")
    end
  end
end
