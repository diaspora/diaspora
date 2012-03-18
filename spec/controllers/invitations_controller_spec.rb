#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe InvitationsController do

  before do
    AppConfig[:open_invitations] = true
    @user   = alice
    @invite = {'email_inviter' => {'message' => "test", 'emails' => "abc@example.com"}}
  end

  describe "#create" do
    before do
      sign_in :user, @user
      @controller.stub!(:current_user).and_return(@user)
      request.env["HTTP_REFERER"]= 'http://test.host/cats/foo'
    end

    it 'creates an EmailInviter'  do
      inviter = stub(:emails => ['mbs@gmail.com'], :send! => true)
      EmailInviter.should_receive(:new).with(@invite['email_inviter']['emails'], @user, @invite['email_inviter']).
        and_return(inviter)
      post :create,  @invite
    end

    it "redirects if invitations are closed" do
      open_bit = AppConfig[:open_invitations]
      AppConfig[:open_invitations] = false

      post :create, @invite
      response.should be_redirect
      AppConfig[:open_invitations] = open_bit
    end

    it 'returns to the previous page on success' do
      post :create, @invite
      response.should redirect_to("http://test.host/cats/foo")
    end
  end

  describe '#new' do
    it 'renders' do
      sign_in :user, @user
      get :new
    end
  end
end
