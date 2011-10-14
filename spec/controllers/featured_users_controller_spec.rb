require 'spec_helper'

describe FeaturedUsersController do

  describe "GET 'index'" do
    it "should be successful" do
      sign_in alice
      get 'index'
      response.should be_success
    end
  end

end
