# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe AdminsController, :type => :controller do
  before do
    @user = FactoryGirl.create :user
    sign_in @user, scope: :user
  end

  describe "#dashboard" do
    context "admin not signed in" do
      it "is behind redirect_unless_admin" do
        get :dashboard
        expect(response).to redirect_to stream_path
      end
    end

    context "admin signed in" do
      before do
        Role.add_admin(@user.person)
        @post = bob.post(:status_message, text: "hello", to: bob.aspects.first.id)
        @post_report = alice.reports.create(
          item_id: @post.id, item_type: "Post",
          text: "offensive content"
        )
      end

      it "succeeds" do
        get :dashboard
        expect(response).to be_success
      end

      it "warns the user about unreviewed reports" do
        get :dashboard
        expect(response.body).to match("reports-warning")
        expect(response.body).to include(I18n.t("report.unreviewed_reports", count: 1))
      end

      it "doesn't show a report warning if there are no unreviewed reports" do
        @post_report.mark_as_reviewed
        get :dashboard
        expect(response.body).not_to match("reports-warning")
      end
    end
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
        get :user_search, params: {admins_controller_user_search: {username: @user.username}}
        expect(assigns[:users]).to eq([@user])
      end

      it 'searches on email' do
        get :user_search, params: {admins_controller_user_search: {email: @user.email}}
        expect(assigns[:users]).to eq([@user])
      end

      it 'searches on age < 13 (COPPA)' do
        u_13 = FactoryGirl.create(:user)
        u_13.profile.birthday = 10.years.ago.to_date
        u_13.profile.save!

        o_13 = FactoryGirl.create(:user)
        o_13.profile.birthday = 20.years.ago.to_date
        o_13.profile.save!

        get :user_search, params: {admins_controller_user_search: {under13: "1"}}

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
        get :admin_inviter, params: {identifier: "bob@moms.com"}
        get :admin_inviter, params: {identifier: "bob@moms.com"}
        expect(response).to be_redirect
      end

      it 'invites a new user' do
        expect(EmailInviter).to receive(:new).and_return(double.as_null_object)
        get :admin_inviter, params: {identifier: "bob@moms.com"}
        expect(response).to redirect_to user_search_path
        expect(flash.notice).to include("invitation sent")
      end

      it "doesn't invite an existing user" do
        get :admin_inviter, params: {identifier: bob.email}
        expect(response).to redirect_to user_search_path
        expect(flash.notice).to include("error sending invite")
      end
    end
  end

  describe '#stats' do
    before do
      Role.add_admin(@user.person)
    end

    it "succeeds and renders stats" do
      get :stats
      expect(response).to be_success
      expect(response).to render_template(:stats)
      expect(response.body).to include(
        I18n.translate(
          "admins.stats.display_results", segment: "<strong>#{I18n.translate('admins.stats.daily')}</strong>"
        )
      )
    end

    it "succeeds and renders stats for different ranges" do
      %w(week 2weeks month).each do |range|
        get :stats, params: {range: range}
        expect(response).to be_success
        expect(response).to render_template(:stats)
        expect(response.body).not_to include(
          I18n.translate(
            "admins.stats.display_results", segment: "<strong>#{I18n.translate('admins.stats.daily')}</strong>"
          )
        )
        expect(response.body).to include(
          I18n.translate(
            "admins.stats.display_results", segment: "<strong>#{I18n.translate("admins.stats.#{range}")}</strong>"
          )
        )
      end
    end
  end
end
