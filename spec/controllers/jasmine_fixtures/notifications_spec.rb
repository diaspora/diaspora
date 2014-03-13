require 'spec_helper'

describe NotificationsController do
  describe '#index' do
    before do
      sign_in :user, alice
      @post = FactoryGirl.create(:status_message)
      FactoryGirl.create(:notification, :recipient => alice, :target => @post)
      get :read_all
      FactoryGirl.create(:notification, :recipient => alice, :target => @post)
      eve.share_with(alice.person, eve.aspects.first)
    end

    it "generates a jasmine fixture", :fixture => true do
      get :index
      save_fixture(html_for("body"), "notifications")
    end
  end
end
