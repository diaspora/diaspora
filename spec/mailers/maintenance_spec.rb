# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Maintenance, :type => :mailer do
  describe 'create warning' do
    before do
      @removal_timestamp = Time.now + 3.days
      @user = FactoryGirl.create(:user_with_aspect, :username => "local", :remove_after => @removal_timestamp)
    end

    it "#should deliver successfully" do
      expect {
        Maintenance.account_removal_warning(@user).deliver_now
      }.to_not raise_error
    end

    it "#should be added to the delivery queue" do
      expect {
        Maintenance.account_removal_warning(@user).deliver_now
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "#should include correct recipient" do
      Maintenance.account_removal_warning(@user).deliver_now
      expect(ActionMailer::Base.deliveries.last.to[0]).to include(@user.email)
    end

    it "#should include after inactivity days from settings" do
      Maintenance.account_removal_warning(@user).deliver_now
      expect(ActionMailer::Base.deliveries.last.body.parts[0].body.raw_source).to include("for #{AppConfig.settings.maintenance.remove_old_users.after_days} days")
    end

    it "#should include timestamp for account removal" do
      Maintenance.account_removal_warning(@user).deliver_now
      expect(ActionMailer::Base.deliveries.last.body.parts[0].body.raw_source).to include("sign in to your account before #{@removal_timestamp.utc}")
    end
  end
end
