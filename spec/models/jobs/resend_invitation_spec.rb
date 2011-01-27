#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Job::ResendInvitation do
  describe '#perfom_delegate' do
    it 'should call .resend on the object' do
      user = alice
      aspect = user.aspects.create(:name => "cats")
      user.invite_user(aspect.id, 'email', "a@a.com", "")
      invitation = user.reload.invitations_from_me.first

      #Notification.should_receive(:notify).with(instance_of(User), instance_of(StatusMessage), instance_of(Person))
      Invitation.stub(:where).with(:id => invitation.id ).and_return([invitation])
      invitation.should_receive(:resend)
      Job::ResendInvitation.perform_delegate(invitation.id)
    end
  end
end
