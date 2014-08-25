#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AdminsController, :type => :controller do
  before do
    @user = FactoryGirl.create :user
    sign_in :user, @user
  end

  describe '#user_search' do
    context 'admin not signed in' do
      it 'is behind redirect_unless_admin' do
        get :user_search
        expect(response).to redirect_to stream_path
      end
    end

    context 'admin signed in' do
      before do
        Role.add_admin(@user.person)
      end

      it 'succeeds and renders user_search' do
        get :user_search
        expect(response).to be_success
        expect(response).to render_template(:user_search)
      end

      it 'assigns users to an empty array if nothing is searched for' do
        get :user_search
        expect(assigns[:users]).to eq([])
      end

      it 'searches on username' do
        get :user_search, admins_controller_user_search: { username: @user.username }
        expect(assigns[:users]).to eq([@user])
      end

      it 'searches on email' do
        get :user_search, admins_controller_user_search: { email: @user.email }
        expect(assigns[:users]).to eq([@user])
      end

      it 'searches on age < 13 (COPPA)' do
        u_13 = FactoryGirl.create(:user)
        u_13.profile.birthday = 10.years.ago.to_date
        u_13.profile.save!

        o_13 = FactoryGirl.create(:user)
        o_13.profile.birthday = 20.years.ago.to_date
        o_13.profile.save!

        get :user_search, admins_controller_user_search: { under13: '1' }

        expect(assigns[:users]).to include(u_13)
        expect(assigns[:users]).not_to include(o_13)
      end
    end
  end

  describe '#admin_inviter' do
    context 'admin not signed in' do
      it 'is behind redirect_unless_admin' do
        get :admin_inviter
        expect(response).to redirect_to stream_path
      end
    end

    context 'admin signed in' do
      before do
        Role.add_admin(@user.person)
      end

      it 'does not die if you do it twice' do
        get :admin_inviter, :identifier => 'bob@moms.com'
        get :admin_inviter, :identifier => 'bob@moms.com'
        expect(response).to be_redirect
      end

      it 'invites a new user' do
        expect(EmailInviter).to receive(:new).and_return(double.as_null_object)
        get :admin_inviter, :identifier => 'bob@moms.com'
        expect(response).to redirect_to user_search_path
        expect(flash.notice).to include("invitation sent")
      end
    end
  end

  describe '#stats' do
    before do
      Role.add_admin(@user.person)
    end

    it 'succeeds and renders stats' do
      get :stats
      expect(response).to be_success
      expect(response).to render_template(:stats)
    end
  end
end
