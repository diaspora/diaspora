#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, 'lib/rake_helpers.rb')
include RakeHelpers
describe RakeHelpers do
  before do
    @csv = File.join(Rails.root, 'spec/fixtures/test.csv')
  end
  describe '#process_emails' do
    before do
      Devise.mailer.deliveries = []
    end
    it 'should send emails to each backer' do
      Invitation.should_receive(:create_invitee).exactly(3).times
      process_emails(@csv, 100, 1)
    end

    it 'should not send the email to the same email twice' do
      process_emails(@csv, 100, 1)

      Devise.mailer.deliveries.count.should == 3
      process_emails(@csv, 100, 1)

      Devise.mailer.deliveries.count.should == 3
    end

    it 'should make a user with 5 invites' do
      User.count.should == 0

      process_emails(@csv, 1, 1)
      
      User.count.should == 1
      User.first.invites.should == 5
    end

  end
end

