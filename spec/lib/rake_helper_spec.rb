#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, 'lib/rake_helpers.rb')
describe RakeHelpers do
  before do
    @csv = File.join(Rails.root, 'spec/fixtures/test.csv')
  end
  describe '#process_emails' do
    it 'should send emails to each backer' do
      pending
      Invitation.should_receive(:create_invitee).exactly(3).times
      RakeHelpers::process_emails(@csv, 100, 0)

    end
  end
end

