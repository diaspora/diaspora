#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Jobs::ResendInvitation do
  describe '#perfom' do
    it 'should call .resend on the object' do
      invite = FactoryGirl.build(:invitation, :service => 'email', :identifier => 'foo@bar.com')

      Invitation.stub(:find).and_return(invite)
      invite.should_receive(:resend)
      Jobs::ResendInvitation.perform(invite.id)
    end
  end
end
