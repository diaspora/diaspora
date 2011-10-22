require 'spec_helper'

describe CommunitySpotlightController do
  describe "GET 'index'" do
    it "should be successful" do
      sign_in alice
      get 'index'
      response.should be_success
    end
  end
end
