# frozen_string_literal: true

describe Api::OpenidConnect::UserInfoController do
  include Rails.application.routes.url_helpers

  let!(:auth_with_read_and_ppid) {
    FactoryGirl.create(:auth_with_profile_and_ppid)
  }

  let!(:access_token_with_read) { auth_with_read_and_ppid.create_access_token.to_s }

  describe "#show" do
    before do
      @user = auth_with_read_and_ppid.user
      get api_openid_connect_user_info_path, params: {access_token: access_token_with_read}
    end

    it "shows the info" do
      json_body = JSON.parse(response.body)
      expected_sub =
        @user.pairwise_pseudonymous_identifiers.find_or_create_by(identifier: "https://example.com/uri").guid
      expect(json_body["sub"]).to eq(expected_sub)
      expect(json_body["nickname"]).to eq(@user.name)
      expect(json_body["profile"]).to end_with(api_v1_user_path)
    end
  end
end
