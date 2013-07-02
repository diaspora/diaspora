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
      @referer = 'http://test.host/cats/foo'
      request.env["HTTP_REFERER"] = @referer
    end

    context "no emails" do
      before do
        @invite = {'email_inviter' => {'message' => "test", 'emails' => ""}}
      end

      it 'does not create an EmailInviter' do
        Workers::Mail::InviteEmail.should_not_receive(:perform_async)
        post :create,  @invite
      end

      it 'returns to the previous page' do
        post :create, @invite
        response.should redirect_to @referer
      end

      it 'flashes an error' do
        post :create, @invite
        flash[:error].should == I18n.t("invitations.create.empty")
      end
    end

    context 'only valid emails' do
      before do
        @emails = 'mbs@gmail.com'
        @invite = {'email_inviter' => {'message' => "test", 'emails' => @emails}}
      end

      it 'creates an InviteEmail worker'  do
        inviter = stub(:emails => [@emails], :send! => true)
        Workers::Mail::InviteEmail.should_receive(:perform_async).with(@invite['email_inviter']['emails'], @user.id, @invite['email_inviter'])
        post :create,  @invite
      end

      it 'returns to the previous page on success' do
        post :create, @invite
        response.should redirect_to @referer
      end

      it 'flashes a notice' do
        post :create, @invite
        expected =  I18n.t('invitations.create.sent', :emails => @emails.split(',').join(', '))
        flash[:notice].should == expected
      end
    end

    context 'only invalid emails' do
      before do
        @emails = 'invalid_email'
        @invite = {'email_inviter' => {'message' => "test", 'emails' => @emails}}
      end

      it 'does not create an InviteEmail worker' do
        Workers::Mail::InviteEmail.should_not_receive(:perform_async)
        post :create,  @invite
      end

      it 'returns to the previous page' do
        post :create, @invite
        response.should redirect_to @referer
      end

      it 'flashes an error' do
        post :create, @invite

        expected =  I18n.t('invitations.create.rejected') + @emails.split(',').join(', ')
        flash[:error].should == expected
      end
    end

    context 'mixed valid and invalid emails' do
      before do
        @valid_emails = 'foo@bar.com,mbs@gmail.com'
        @invalid_emails = 'invalid'
        @invite = {'email_inviter' => {'message' => "test", 'emails' =>
                                       @valid_emails + ',' + @invalid_emails}}
      end

      it 'creates an InviteEmail worker'  do
        inviter = stub(:emails => [@emails], :send! => true)
        Workers::Mail::InviteEmail.should_receive(:perform_async).with(@valid_emails, @user.id, @invite['email_inviter'])
        post :create,  @invite
      end

      it 'returns to the previous page' do
        post :create, @invite
        response.should redirect_to @referer
      end

      it 'flashes a notice' do
        post :create, @invite
        expected =  I18n.t('invitations.create.sent', :emails =>
                          @valid_emails.split(',').join(', ')) +
                          '. ' + I18n.t('invitations.create.rejected') +
                          @invalid_emails.split(',').join(', ')
        flash[:error].should == expected
      end
    end

    it 'redirects if invitations are closed' do
      open_bit = AppConfig.settings.invitations.open?
      AppConfig.settings.invitations.open =  false

      post :create, @invite
      response.should be_redirect
      AppConfig.settings.invitations.open = open_bit
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

  describe '.valid_email?' do
    it 'returns false for empty email' do
      subject.send(:valid_email?, '').should be false
    end

    it 'returns false for email without @-sign' do
      subject.send(:valid_email?, 'foo').should be false
    end

    it 'returns true for valid email' do
      subject.send(:valid_email?, 'foo@bar.com').should be true
    end
  end

  describe '.html_safe_string_from_session_array' do
    it 'returns "" for blank session[key]' do
      subject.send(:html_safe_string_from_session_array, :blank).should eq ""
    end

    it 'returns "" if session[key] is not an array' do
      session[:test_key] = "test"
      subject.send(:html_safe_string_from_session_array, :test_key).should eq ""
    end

    it 'returns the correct value' do
      session[:test_key] = ["test", "foo"]
      subject.send(:html_safe_string_from_session_array, :test_key).should eq "test, foo"
    end

    it 'sets session[key] to nil' do
      session[:test_key] = ["test"]
      subject.send(:html_safe_string_from_session_array, :test_key)
      session[:test_key].should be nil
    end
  end
end
