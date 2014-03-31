#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Report do
  describe '#make_notification' do
    before do
      @user = bob
      Role.add_admin(@user)
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
  end
end
