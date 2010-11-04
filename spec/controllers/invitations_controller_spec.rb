#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe InvitationsController do
  include Devise::TestHelpers

  render_views

  let!(:user) {make_user}
  let!(:aspect){user.aspects.create(:name => "WIN!!")}
  
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]

    sign_in :user, user

    @controller.stub!(:current_user).and_return(user)
  end

  describe "#create" do
    
    it 'invites the requested user' do
      user.should_receive(:invite_user).once
      post :create, "user"=>{"invite_messages"=>"test", "aspects"=> aspect.id.to_s, "email"=>"abc@example.com"}
    end

    
  end
end

