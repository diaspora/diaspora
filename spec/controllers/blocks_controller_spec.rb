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

    it "calls #disconnect_if_contact" do
      expect(@controller).to receive(:disconnect_if_contact).with(bob.person)
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

  describe "#disconnect_if_contact" do
    before do
      allow(@controller).to receive(:current_user).and_return(alice)
    end

    it "calls disconnect with the force option if there is a contact for a given user" do
      contact = alice.contact_for(bob.person)
      allow(alice).to receive(:contact_for).and_return(contact)
      expect(alice).to receive(:disconnect).with(contact)
      @controller.send(:disconnect_if_contact, bob.person)
    end

    it "doesn't call disconnect if there is a contact for a given user" do
      expect(alice).not_to receive(:disconnect)
      @controller.send(:disconnect_if_contact, eve.person)
    end
  end
end
