#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AdminsController do
  before do
    @user = FactoryGirl.create :user
    sign_in :user, @user
  end

  describe '#user_search' do
    context 'admin not signed in' do
      it 'is behind redirect_unless_admin' do
        get :user_search
        response.should redirect_to stream_path
      end
    end

    context 'admin signed in' do
      before do
        Role.add_admin(@user.person)
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

      it 'searches on username' do
        get :user_search, admins_controller_user_search: { username: @user.username }
        assigns[:users].should == [@user]
      end

      it 'searches on email' do
        get :user_search, admins_controller_user_search: { email: @user.email }
        assigns[:users].should == [@user]
      end

      it 'searches on age < 13 (COPPA)' do
        u_13 = FactoryGirl.create(:user)
        u_13.profile.birthday = 10.years.ago.to_date
        u_13.profile.save!

        o_13 = FactoryGirl.create(:user)
        o_13.profile.birthday = 20.years.ago.to_date
        o_13.profile.save!

        get :user_search, admins_controller_user_search: { under13: '1' }

        assigns[:users].should include(u_13)
        assigns[:users].should_not include(o_13)
      end
    end
  end

  describe '#admin_inviter' do
    context 'admin not signed in' do
      it 'is behind redirect_unless_admin' do
        get :admin_inviter
        response.should redirect_to stream_path
      end
    end

    context 'admin signed in' do
      before do
        Role.add_admin(@user.person)
      end

      it 'does not die if you do it twice' do
        get :admin_inviter, :identifier => 'bob@moms.com'
        get :admin_inviter, :identifier => 'bob@moms.com'
        response.should be_redirect
      end

      it 'invites a new user' do
        EmailInviter.should_receive(:new).and_return(double.as_null_object)
        get :admin_inviter, :identifier => 'bob@moms.com'
        response.should redirect_to user_search_path
        flash.notice.should include("invitation sent")
      end
    end
  end

  describe '#stats' do
    before do
      Role.add_admin(@user.person)
    end

    it 'succeeds and renders stats' do
      get :stats
      response.should be_success
      response.should render_template(:stats)
    end
  end
end
