#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Maintenance, :type => :mailer do
  describe 'create warning' do
    before do
      @removal_timestamp = Time.now + 3.days
      @user = FactoryGirl.create(:user_with_aspect, :username => "local", :remove_after => @removal_timestamp) 
    end
    
    it "#should deliver successfully" do
      expect {
        Maintenance.account_removal_warning(@user).deliver
      }.to_not raise_error
    end
    
    it "#should be added to the delivery queue" do
      expect {
        Maintenance.account_removal_warning(@user).deliver
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "#should include correct recipient" do
      Maintenance.account_removal_warning(@user).deliver
      expect(ActionMailer::Base.deliveries.last.to[0]).to include(@user.email)
    end
    
    it "#should include after inactivity days from settings" do
      Maintenance.account_removal_warning(@user).deliver
      expect(ActionMailer::Base.deliveries.last.body.parts[0].body.raw_source).to include("more than "+AppConfig.settings.maintenance.remove_old_users.after_days.to_s+" days")
    end
    
    it "#should include timestamp for account removal" do
      Maintenance.account_removal_warning(@user).deliver
      expect(ActionMailer::Base.deliveries.last.body.parts[0].body.raw_source).to include("logging into the account before "+@removal_timestamp.utc.to_s)
    end
  end
end
