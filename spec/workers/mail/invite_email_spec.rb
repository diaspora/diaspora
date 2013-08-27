require 'spec_helper'

describe Workers::Mail::InviteEmail do
  let(:emails) { ['foo@bar.com', 'baz@bar.com'] }
  let(:message) { 'get over here!' }
  let(:email_inviter) { double('EmailInviter') }

  it 'creates a new email inviter' do
    EmailInviter.should_receive(:new).with(emails, alice, message: message)
      .and_return(email_inviter)
    email_inviter.should_receive(:send!)
    Workers::Mail::InviteEmail.new.perform(emails, alice, message: message)
  end
end
