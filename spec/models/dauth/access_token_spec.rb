require 'spec_helper'

describe Dauth::AccessToken do
  before { 
    @access_token = FactoryGirl.create(:access_token)
  }

  describe "validation" do

    describe "of object from fractory" do
      it "must be ok" do
        @access_token.should be_valid
      end
    end

    describe "of token" do
      describe "requires presence" do
        before{ @access_token.token = ""}
        it {@access_token.should_not be_valid}
      end
    end

    describe "of refresh_token_id" do
      describe "requires presence" do
        before{ @access_token.refresh_token_id = ""}
        it {@access_token.should_not be_valid}
      end
    end

    describe "of secret" do
      describe "requires presence" do
        before{ @access_token.secret = ""}
        it {@access_token.should_not be_valid}
      end
    end
  end
end
