#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Job::ResendInvitation do
  describe '#perfom' do
    it 'should call .resend on the object' do
      invite = Factory(:invitation, :service => 'email', :identifier => 'foo@bar.com')

      Invitation.stub(:find).and_return(invite)
      invite.should_receive(:resend)
      Job::ResendInvitation.perform(invite.id)
    end
  end
end
