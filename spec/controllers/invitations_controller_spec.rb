#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe InvitationsController do

  before do
    AppConfig.settings.invitations.open = true
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
      open_bit = AppConfig.settings.invitations.open?
      AppConfig.settings.invitations.open =  false

      post :create, @invite
      response.should be_redirect
      AppConfig.settings.invitations.open = open_bit
    end

    it 'returns to the previous page on success' do
      post :create, @invite
      response.should redirect_to("http://test.host/cats/foo")
    end
  end

  describe '#email' do

    it 'succeeds' do
      get :email, :invitation_code => "anycode"
      response.should be_success
    end

    context 'legacy invite tokens' do
      def get_email
        get :email, :invitation_token => @invitation_token
      end

      context 'invalid token' do
        @invitation_token = "invalidtoken"

        it 'redirects and flashes if the invitation token is invalid' do
          get_email

          response.should be_redirect
          response.should redirect_to root_url
        end

        it 'flashes an error if the invitation token is invalid' do
          get_email

          flash[:error].should == I18n.t("invitations.check_token.not_found")
        end
      end
    end
  end

  describe '#new' do
    it 'renders' do
      sign_in :user, @user
      get :new
    end
  end

  describe 'redirect logged out users to the sign in page' do
    it 'redriects #new' do
      get :new
      response.should be_redirect
      response.should redirect_to new_user_session_path
    end

    it 'redirects #create' do
      post :create
      response.should be_redirect
      response.should redirect_to new_user_session_path
    end
  end
end
