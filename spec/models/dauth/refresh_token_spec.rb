require 'spec_helper'

describe Dauth::RefreshToken do
  before {
    @refresh_token = FactoryGirl.create(:refresh_token)
  }
  describe "validation" do

    describe "of object from fractory" do
      it "must be ok" do
        @refresh_token.should be_valid
      end
    end

    describe "of refresh token" do
      describe "requires presence" do
        before{ @refresh_token.token ="" }
        it {@refresh_token.should_not be_valid}
      end
    end

    describe "of app id" do
      before{ @refresh_token.app_id ="" }
      it "requires presence" do
        @refresh_token.should_not be_valid
      end
    end

    describe "of scopes" do
      before{ @refresh_token.scopes ="" }
      it "requires presence" do
        @refresh_token.should_not be_valid
      end
    end

    describe "of secret" do
      before{ @refresh_token.secret ="" }
      it "requires presence" do
        @refresh_token.should_not be_valid
      end
    end
  end
end
