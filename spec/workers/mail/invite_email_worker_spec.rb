# frozen_string_literal: true

describe Mail::InviteEmailWorker do
  let(:emails) { ['foo@bar.com', 'baz@bar.com'] }
  let(:message) { 'get over here!' }
  let(:email_inviter) { double('EmailInviter') }

  it 'creates a new email inviter' do
    expect(EmailInviter).to receive(:new).with(emails, alice, {message: message}).and_return(email_inviter)
    expect(email_inviter).to receive(:send!)
    Mail::InviteEmailWorker.new.perform(emails, alice.id, message: message)
  end
end
