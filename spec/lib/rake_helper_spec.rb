#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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
      expect{
        process_emails(@csv, 100, 1, false)
        }.to change(User, :count).by(3)
    end

    it 'should not send the email to the same email twice' do
      process_emails(@csv, 100, 1, false)

      Devise.mailer.deliveries.count.should == 3
      process_emails(@csv, 100, 1, false)

      Devise.mailer.deliveries.count.should == 3
    end
  end
end

