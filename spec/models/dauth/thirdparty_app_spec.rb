require 'spec_helper'

describe Dauth::ThirdpartyApp do
  before {
    @thirdparty_app = FactoryGirl.create(:thirdparty_app)
  }
  describe "validation" do

    describe "of object from fractory" do
      it "must be ok" do
        @thirdparty_app.should be_valid
      end
    end

    describe "of app id" do
      before{ @thirdparty_app.app_id = "" }
      it "requires presence" do
        @thirdparty_app.should_not be_valid
      end
    end

    describe "of developer handle" do
      before{ @thirdparty_app.dev_handle = "" }
      it "requires presence" do
        @thirdparty_app.should_not be_valid
      end
    end
  end
end
