require "spec_helper"

describe Api::V0::PostsController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }

  before do
    @aspect = auth.user.aspects.first
    @status = auth.user.post(:status_message, text: "This is a status message", public: true, to: "all")
  end

  describe "#aspect" do
    it "contains expected aspect message" do
      get api_v0_aspects_stream_path(a_ids: [@aspect.id]), access_token: access_token
      expect(response.body).to include("This is a status message")
    end

    it "does not save to requested aspects to session" do
      get api_v0_aspects_stream_path(a_ids: [@aspect.id]), access_token: access_token
      expect(session[:a_ids]).to be_nil
    end
  end
end
