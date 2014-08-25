#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Report, :type => :mailer do
  describe '#make_notification' do
    before do
      @remote = FactoryGirl.create(:person, :diaspora_handle => "remote@remote.net")
      @user = FactoryGirl.create(:user_with_aspect, :username => "local") 
      Role.add_admin(@user.person)
    end
    
    it "should deliver successfully" do
      expect {
        ReportMailer.new_report('post', 666)
      }.to_not raise_error
    end
    
    it "should be added to the delivery queue" do
      expect {
        ReportMailer.new_report('post', 666)
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it "should include correct recipient" do
      ReportMailer.new_report('post', 666)
      expect(ActionMailer::Base.deliveries[0].to[0]).to include(@user.email)
    end
  end
end
