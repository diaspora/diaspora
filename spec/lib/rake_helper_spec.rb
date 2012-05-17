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
      @old_admin = AppConfig[:admin_account]
      AppConfig[:admin_account] = Factory(:user).username
    end

    after do
      AppConfig[:admin_account] = @old_admin
    end

    it 'should send emails to each email' do

      EmailInviter.should_receive(:new).exactly(3).times.and_return(stub.as_null_object)
      process_emails(@csv, 100, 1, false)
    end
  end
end

