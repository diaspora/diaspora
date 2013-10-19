require 'spec_helper'

describe Manifest do
  describe "validation" do
    describe "of object from fractory" do
      it "must be ok" do
        FactoryGirl.create(:manifest).should be_valid
      end
    end

    describe "of app_name" do
      it "requires presence" do
        FactoryGirl.build(:manifest, app_name: "").should_not be_valid
      end
    end

    describe "of app_description" do
      it "should not be longer than 500 characters" do
        FactoryGirl.build(:manifest, app_description: "a"*505).should_not be_valid
      end
    end

    describe "of callback_url" do
      it "requires presence" do
        FactoryGirl.build(:manifest, callback_url: "").should_not be_valid
      end
      
      it "validate format of a valid url" do
        FactoryGirl.build(:manifest, callback_url: "http://test.com").should be_valid
      end
      
      it "validate format of a non valid url" do
        FactoryGirl.build(:manifest, callback_url: "not a valid url").should_not be_valid
      end
    end

    describe "of redirect_url" do
      it "requires presence" do
        FactoryGirl.build(:manifest, redirect_url: "").should_not be_valid
      end
      
      it "validate format of a valid url" do
        FactoryGirl.build(:manifest, redirect_url: "https://test.com").should be_valid
      end

      it "validate format of a non valid url" do
        FactoryGirl.build(:manifest, redirect_url: "not a valid url").should_not be_valid
      end
    end
    
    describe "of manifest_hash" do
      it "should return a hash correctly describing the manifest" do
        dev = FactoryGirl.create(:user)
        dev.person = FactoryGirl.create(:person, diaspora_handle: "test@pod.com")
        manifest = FactoryGirl.create(:manifest, :dev => dev)

        expected_hash = {
          :dev_handle => "test@pod.com",          
          :manifest_version => "1.0",
          :app_details => { :name=>"cool birds", :id=> manifest.app_id, :description=>"Birds in this app are cool!", :version=>"1" },
          :callback_url => "http://coolbirds.com/diasporaapp",
          :redirect_url => "http://coolbirds.com/welcome",
          :access => ["post_write", "contact_list_read"]
        }

        manifest.manifest_hash.should == expected_hash
      end
    end
  end
end
