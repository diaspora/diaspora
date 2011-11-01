require 'spec_helper'

describe BlocksController do
  describe "#create" do
    before do
      sign_in alice
    end

    it "should create a block" do
      expect {
        post :create, :block => { :person_id => 2 }
      }.should change { alice.blocks.count }.by(1)
    end

    it "should redirect to back" do
      post :create, :block => { :person_id => 2 }

      response.should be_redirect
    end

    it "notifies the user" do
      post :create, :block => { :person_id => 2 }

      flash.should_not be_empty
    end
  end
end