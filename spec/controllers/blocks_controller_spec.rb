# frozen_string_literal: true

describe BlocksController, :type => :controller do
  before do
    sign_in alice
  end

  describe "#create" do
    it "creates a block" do
      expect {
        post :create, params: {block: {person_id: eve.person.id}}, format: :json
      }.to change { alice.blocks.count }.by(1)
    end

    it "responds with 204" do
      post :create, params: {block: {person_id: eve.person.id}}, format: :json
      expect(response.status).to eq(204)
    end

    it "calls #send_message" do
      expect(@controller).to receive(:send_message).with(an_instance_of(Block))
      post :create, params: {block: {person_id: bob.person.id}}, format: :json
    end
  end

  describe "#destroy" do
    before do
      @block = alice.blocks.create(:person => eve.person)
    end

    it "redirects back" do
      delete :destroy, params: {id: @block.id}
      expect(response).to be_redirect
    end

    it "notifies the user" do
      delete :destroy, params: {id: @block.id}
      expect(flash[:notice]).to eq(I18n.t("blocks.destroy.success"))
    end

    it "sends a message" do
      retraction = double
      expect(ContactRetraction).to receive(:for).with(@block).and_return(retraction)
      expect(retraction).to receive(:defer_dispatch).with(alice)
      delete :destroy, params: {id: @block.id}
    end

    it "responds with 204 with json" do
      delete :destroy, params: {id: @block.id}, format: :json
      expect(response.status).to eq(204)
    end

    it "redirects back on mobile" do
      delete :destroy, params: {id: @block.id}, format: :mobile
      expect(response).to be_redirect
    end

    it "removes a block" do
      expect {
        delete :destroy, params: {id: @block.id}, format: :json
      }.to change { alice.blocks.count }.by(-1)
    end

    it "handles when the block to delete doesn't exist" do
      delete :destroy, params: {id: -1}
      expect(flash[:error]).to eq(I18n.t("blocks.destroy.failure"))
    end
  end

  describe "#send_message" do
    before do
      allow(@controller).to receive(:current_user).and_return(alice)
    end

    it "calls disconnect if there is a contact for a given user" do
      block = alice.blocks.create(person: bob.person)
      contact = alice.contact_for(bob.person)
      expect(alice).to receive(:contact_for).and_return(contact)
      expect(alice).to receive(:disconnect).with(contact)
      expect(Diaspora::Federation::Dispatcher).not_to receive(:defer_dispatch)
      @controller.send(:send_message, block)
    end

    it "queues a message with the block if the person is remote and there is no contact for a given user" do
      block = alice.blocks.create(person: remote_raphael)
      expect(alice).not_to receive(:disconnect)
      expect(Diaspora::Federation::Dispatcher).to receive(:defer_dispatch).with(alice, block)
      @controller.send(:send_message, block)
    end

    it "does nothing if the person is local and there is no contact for a given user" do
      block = alice.blocks.create(person: eve.person)
      expect(alice).not_to receive(:disconnect)
      expect(Diaspora::Federation::Dispatcher).not_to receive(:defer_dispatch)
      @controller.send(:send_message, block)
    end
  end
end
