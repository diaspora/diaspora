#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe InvitationsController do
  render_views
  let(:user) {Factory.create :user}

  before do
    sign_in :user, user
  end

  context 'inviting another user' do
    it 'should create an invited user and add keep track of an invitor' do
      debugger
      params = {"user" => {"email" => "test@example.com"}}
      post :create, params
      #invitee = inviter.invite_user(:email => "test@example.com")
      #invitee.inviters.includes?(inviter).should be true
    end
  end

end
