require 'spec_helper'

describe BlocksController do
  before do
    sign_in alice
  end

  describe "#create" do
    it "creates a block" do
      expect {
        post :create, :block => { :person_id => 2 }
      }.should change { alice.blocks.count }.by(1)
    end

    it "redirects back" do
      post :create, :block => { :person_id => 2 }

      response.should be_redirect
    end

    it "notifies the user" do
      post :create, :block => { :person_id => 2 }

      flash.should_not be_empty
    end
  end

  describe "#destroy" do
    before do
      @block = alice.blocks.create(:person => eve.person)
    end

    it "redirects back" do
      delete :destroy, :id => @block.id
      response.should be_redirect
    end

    it "removes a block" do
      expect {
        delete :destroy, :id => @block.id
      }.should change { alice.blocks.count }.by(-1)
    end
  end
end
