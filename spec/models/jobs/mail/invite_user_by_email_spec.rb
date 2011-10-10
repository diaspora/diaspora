require 'spec_helper'

describe Jobs::Mail::InviteUserByEmail do
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
    Jobs::Mail::InviteUserByEmail.perform(invitation.id)
  end
end
