require 'spec_helper'

describe Job::InviteUserByEmail do
  before do
    @sender = alice
    @email = 'bob@bob.com'
    @aspect_id = alice.aspects.first.id
    @message = 'invite message'

    User.stub(:find){ |id|
      if id == @sender.id
        @sender
      else
        nil
      end
    }
  end

  it 'calls invite_user with email param' do
    @sender.should_receive(:invite_user).with(@aspect_id, 'email', @email, @message)
    Job::InviteUserByEmail.perform(@sender.id, @email, @aspect_id, @message)
  end
end
