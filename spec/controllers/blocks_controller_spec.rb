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
end
