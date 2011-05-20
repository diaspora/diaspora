#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ContactsController do
  before do
    sign_in :user, alice
    @controller.stub(:current_user).and_return(alice)
  end

  describe '#sharing' do
    it "succeeds" do
      get :sharing
      response.should be_success
    end

    it 'eager loads the aspects' do
      get :sharing
      assigns[:contacts].first.aspect_memberships.loaded?.should be_true
    end

    it "assigns only the people sharing with you with 'share_with' flag" do
      get :sharing, :id => 'share_with'
      assigns[:contacts].to_set.should == alice.contacts.sharing.to_set
    end
  end
end
