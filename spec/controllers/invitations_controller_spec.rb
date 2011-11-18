#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe InvitationsController do
  include Devise::TestHelpers

  before do
    AppConfig[:open_invitations] = true
    @user   = alice
    @aspect = @user.aspects.first
    @invite = {:invite_message=>"test", :aspects=> @aspect.id.to_s, :email=>"abc@example.com"}

    request.env["devise.mapping"] = Devise.mappings[:user]
    Webfinger.stub_chain(:new, :fetch).and_return(Factory(:person))
  end

  describe "#create" do
    before do
      sign_in :user, @user
      @controller.stub!(:current_user).and_return(@user)
      request.env["HTTP_REFERER"]= 'http://test.host/cats/foo'
    end

    it 'saves an invitation'  do
      expect {
        post :create,  :user => @invite
      }.should change(Invitation, :count).by(1)
    end

    it 'handles a comma-separated list of emails' do
      expect{
        post :create, :user => @invite.merge(
        :email => "foofoofoofoo@example.com, mbs@gmail.com")
      }.should change(Invitation, :count).by(2)
    end

    it 'handles a comma-separated list of emails with whitespace' do
      expect {
        post :create, :user => @invite.merge(
          :email => "foofoofoofoo@example.com   ,        mbs@gmail.com")
          }.should change(Invitation, :count).by(2)
    end

    it "allows invitations without if invitations are open" do
      open_bit = AppConfig[:open_invitations]
      AppConfig[:open_invitations] = true

      expect{
        post :create, :user => @invite
      }.to change(Invitation, :count).by(1)
      AppConfig[:open_invitations] = open_bit
    end

    it 'returns to the previous page on success' do
      post :create, :user => @invite
      response.should redirect_to("http://test.host/cats/foo")
    end

    it 'strips out your own email' do
      lambda {
        post :create, :user => @invite.merge(:email => @user.email)
      }.should_not change(Invitation, :count)

      expect{
        post :create, :user => @invite.merge(:email => "hello@example.org, #{@user.email}")
      }.should change(Invitation, :count).by(1)
    end
  end

  describe "#email" do
    before do
      invites = Invitation.batch_invite(["foo@example.com"], :message => "hi", :sender => @user, :aspect => @user.aspects.first, :service => 'email', :language => "en-US")
      invites.first.send!
      @invited_user = User.find_by_email("foo@example.com")
    end

    it "succeeds" do
      get :email, :invitation_token => @invited_user.invitation_token
      response.should be_success
    end

    it "shows an error if there's no such invitation token" do
      get :email, :invitation_token => "12345"
      response.should render_template(:token_not_found)
    end
  end

  describe "#update" do
    before do
      invite = Factory(:invitation, :sender => @user, :service => 'email', :identifier => "a@a.com")
      @invited_user = invite.attach_recipient!

      @accept_params = {:user=>
        {:password_confirmation =>"password",
         :email => "a@a.com", 
         :username=>"josh",
         :password=>"password",
         :invitation_token => @invited_user.invitation_token}}

    end

    context 'success' do
      let(:invited) {User.find_by_username(@accept_params[:user][:username])}

      it 'creates a user' do
        put :update, @accept_params
        invited.should_not be_nil
      end

      it 'seeds the aspects' do
        put :update, @accept_params
        invited.aspects.count.should == 4
      end

      it 'adds a contact' do
        lambda { 
          put :update, @accept_params
        }.should change(@user.contacts, :count).by(1)
      end
    end

    context 'failure' do
      before do
        @fail_params = @accept_params
        @fail_params[:user][:username] = @user.username
      end

      it 'stays on the invitation accept form' do
        put :update, @fail_params
        response.location.include?(accept_user_invitation_path).should be_true
      end

      it 'keeps the invitation token' do
        put :update, @fail_params
        response.location.include?("invitation_token=#{@invited_user.invitation_token}").should be_true
      end
    end
  end

  describe '#new' do
    it 'renders' do
      sign_in :user, @user
      get :new
    end
  end

  describe '#resend' do
    before do
      sign_in :user, @user
      @controller.stub!(:current_user).and_return(@user)
      request.env["HTTP_REFERER"]= 'http://test.host/cats/foo'

      invite = Factory(:invitation, :sender => @user, :service => 'email', :identifier => "a@a.com")
      @invited_user = invite.attach_recipient!
    end

    it 'calls resend invitation if one exists' do
      @user.reload.invitations_from_me.count.should == 1
      invitation = @user.invitations_from_me.first
      Resque.should_receive(:enqueue)
      put :resend, :id => invitation.id
    end

    it 'does not send an invitation for a different user' do
      invitation2 = Factory(:invitation, :sender => bob, :service => 'email', :identifier => "a@a.com")

      Resque.should_not_receive(:enqueue)
      put :resend, :id => invitation2.id
    end
  end


  describe '#extract_messages' do
    before do
      sign_in alice
    end
    it 'displays a message that tells the user how many invites were sent, and which REJECTED' do
      post :create, :user => @invite.merge(
        :email => "mbs@gmail.com, foo@bar.com, foo.com, lala@foo, cool@bar.com")
      flash[:notice].should_not be_blank
      flash[:notice].should =~ /foo\.com/
      flash[:notice].should =~ /lala@foo/
    end
  end
end
