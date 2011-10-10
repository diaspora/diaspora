#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Jobs::Mailers::InviteUserByEmail do
  before do
    @sender = alice
    @email = 'bob@bob.com'
    @aspect = alice.aspects.first
    @message = 'invite message'
  end

  it 'calls invite_user with email param' do
    invitation = Invitation.create(:sender => @sender, :identifier => @email, :service => "email", :aspect => @aspect, :message => @message)
    invitation.should_receive(:send!)
    Invitation.stub(:find).and_return(invitation)
    Jobs::Mailers::InviteUserByEmail.perform(invitation.id)
  end
end
