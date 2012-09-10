require 'spec_helper'

describe BlocksController do
  before do
    sign_in alice
  end

  describe "#create" do
    it "creates a block" do
      expect {
        post :create, :block => {:person_id => eve.person.id}
      }.to change { alice.blocks.count }.by(1)
    end

    it "redirects back" do
      post :create, :block => { :person_id => 2 }

      response.should be_redirect
    end

    it "notifies the user" do
      post :create, :block => { :person_id => 2 }

      flash.should_not be_empty
    end

    it "calls #disconnect_if_contact" do
      @controller.should_receive(:disconnect_if_contact).with(bob.person)
      post :create, :block => {:person_id => bob.person.id}
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
      }.to change { alice.blocks.count }.by(-1)
    end
  end

  describe "#disconnect_if_contact" do
    before do
      @controller.stub(:current_user).and_return(alice)
    end

    it "calls disconnect with the force option if there is a contact for a given user" do
      contact = alice.contact_for(bob.person)
      alice.stub(:contact_for).and_return(contact)
      alice.should_receive(:disconnect).with(contact, hash_including(:force => true))
      @controller.send(:disconnect_if_contact, bob.person)
    end

    it "doesn't call disconnect if there is a contact for a given user" do
      alice.should_not_receive(:disconnect)
      @controller.send(:disconnect_if_contact, eve.person)
    end
  end
end
