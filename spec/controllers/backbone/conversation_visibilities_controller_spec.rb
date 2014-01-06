
require 'spec_helper'

describe Backbone::ConversationVisibilitiesController do
  before do
    request.accept = Mime::BACKBONE
  end

  describe '#destroy' do
    before do
      conv = FactoryGirl.create(:conversation_with_message, author: bob.person)
      @vis = conv.conversation_visibilities.where(person_id: bob.person_id).first
    end

    it 'deletes the visibility' do
      sign_in :user, bob
      lambda {
        delete :destroy, id: @vis.id
      }.should change(ConversationVisibility, :count).by(-1)
      expect(response).to be_success
    end

    it "doesn't destroy other users visibilities" do
      sign_in :user, alice
      lambda {
        delete :destroy, id: @vis.id
      }.should_not change(ConversationVisibility, :count)
      expect(response).not_to be_success
    end
  end
end
