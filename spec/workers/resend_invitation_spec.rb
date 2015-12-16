#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Workers::ResendInvitation do
  describe '#perfom' do
    it 'should call .resend on the object' do
      invite = FactoryGirl.build(:invitation, :service => 'email', :identifier => 'foo@bar.com')

      allow(Invitation).to receive(:find).and_return(invite)
      expect(invite).to receive(:resend)
      Workers::ResendInvitation.new.perform(invite.id)
    end
  end
end
