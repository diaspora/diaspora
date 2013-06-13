require 'spec_helper'

describe Dauth::AccessRequest do
  before {
    @access_request = FactoryGirl.create(:access_request)
  }

  describe "validation" do

    describe "of object from fractory" do
      it "must be ok" do
        @access_request.should be_valid
      end
    end

    describe "of auth token" do
      describe "requires presence" do
        before{ @access_request.auth_token ="" }
        it {@access_request.should_not be_valid}
      end
    end

    describe "of callback url" do
      describe "requires presence" do
        before{ @access_request.callback_url ="" }
        it {@access_request.should_not be_valid}
      end
    end

    describe "of scopes" do
      describe "requires presence" do
        before{ @access_request.scopes ="" }
        it {@access_request.should_not be_valid}
      end
    end

    describe "of dev_handle" do
      describe "requires presence" do
        before{ @access_request.dev_handle ="" }
        it {@access_request.should_not be_valid}
      end
    end

    describe "of app_id" do
      describe "requires presence" do
        before{ @access_request.app_id ="" }
        it {@access_request.should_not be_valid}
      end
    end

    describe "of redirect_url" do
      describe "requires presence" do
        before{ @access_request.redirect_url ="" }
        it {@access_request.should_not be_valid}
      end
    end
  end
end
