require "spec_helper"
describe Api::OpenidConnect::UserInfoController do
  let!(:auth_with_read_and_ppid) { FactoryGirl.create(:auth_with_read_and_ppid) }
  let!(:access_token_with_read) { auth_with_read_and_ppid.create_access_token.to_s }

  describe "#show" do
    before do
      @user = auth_with_read_and_ppid.user
      get api_openid_connect_user_info_path, access_token: access_token_with_read
    end

    it "shows the info" do
      json_body = JSON.parse(response.body)
      expected_sub =
        @user.pairwise_pseudonymous_identifiers.find_or_create_by(sector_identifier: "https://example.com/uri").guid
      expect(json_body["sub"]).to eq(expected_sub)
      expect(json_body["nickname"]).to eq(@user.name)
      expect(json_body["profile"]).to eq(File.join(AppConfig.environment.url, "people", @user.guid).to_s)
    end
  end
end
