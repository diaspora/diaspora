#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AdminsController do
  before do
    @user = Factory :user
    sign_in :user, @user
  end

  describe '#user_search' do
    context 'admin not signed in' do
      it 'is behind redirect_unless_admin' do
        get :user_search
        response.should redirect_to root_url
      end
    end

    context 'admin signed in' do
      before do
        AppConfig[:admins] = [@user.username]
      end

      it 'succeeds and renders user_search' do
        get :user_search
        response.should be_success
        response.should render_template(:user_search)
      end

      it 'assigns users to an empty array if nothing is searched for' do
        get :user_search
        assigns[:users].should == []
      end

      it 'should search on username' do
        get :user_search, :user => {:username => @user.username}
        assigns[:users].should == [@user]
      end

      it 'should search on email' do
        get :user_search, :user => {:email => @user.email}
        assigns[:users].should == [@user]
      end

      it 'should search on invitation_identifier' do
        @user.invitation_identifier = "La@foo.com"
        @user.save!
        get :user_search, :user => {:invitation_identifier => @user.invitation_identifier}
        assigns[:users].should == [@user]
      end

      it 'should search on invitation_token' do
        @user.invitation_token = "akjsdhflhasdf"
        @user.save
        get :user_search, :user => {:invitation_token => @user.invitation_token}
        assigns[:users].should == [@user]
      end
    end
  end

  describe '#add_invites' do
    context 'admin not signed in' do
      it 'is behind redirect_unless_admin' do
        get :add_invites
        response.should redirect_to root_url
      end
    end

    context 'admin signed in' do
      before do
        AppConfig[:admins] = [@user.username]
      end

      it "redirects to :back with user id" do
        get :add_invites, :user_id => @user.id
        response.should redirect_to user_search_path(:user => { :id => @user.id })
      end

      it "increases user's invite by 10" do
        expect {
          get :add_invites, :user_id => @user.id
        }.to change { @user.reload.invites }.by(10)
        flash.notice.should include('Great Job')
      end
    end
  end

  describe '#admin_inviter' do
    context 'admin not signed in' do
      it 'is behind redirect_unless_admin' do
        get :admin_inviter
        response.should redirect_to root_url
      end
    end

    context 'admin signed in' do
      before do
        AppConfig[:admins] = [@user.username]
      end

      it 'succeeds' do
        get :admin_inviter, :identifier => 'bob@moms.com'
        response.should be_redirect
      end

      it 'does not die if you do it twice' do
        get :admin_inviter, :identifier => 'bob@moms.com'
        get :admin_inviter, :identifier => 'bob@moms.com'
        response.should be_redirect
      end
      it 'invites a new user' do
        Invitation.should_receive(:create_invitee).with(:service => 'email', :identifier => 'bob@moms.com')
        get :admin_inviter, :identifier => 'bob@moms.com'
        response.should redirect_to user_search_path
        flash.notice.should include("invitation sent")
      end

      it 'passes an existing user to create_invitee' do
        Factory.create(:user, :email => 'bob@moms.com')
        bob = User.where(:email => 'bob@moms.com').first
        Invitation.should_receive(:find_existing_user).with('email', 'bob@moms.com').and_return(bob)
        Invitation.should_receive(:create_invitee).with(:service => 'email', :identifier => 'bob@moms.com', :existing_user => bob)
        get :admin_inviter, :identifier => 'bob@moms.com'
      end
    end
  end

  describe '#stats' do
    before do
      AppConfig[:admins] = [@user.username]
    end

    it 'succeeds and renders stats' do
      get :stats
      response.should be_success
      response.should render_template(:stats)
    end
  end
end
