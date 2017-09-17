# frozen_string_literal: true

describe Notifications::StartedSharing, type: :model do
  let(:contact) { alice.contact_for(bob.person) }
  let(:started_sharing_notification) { Notifications::StartedSharing.new(recipient: alice) }

  describe ".notify" do
    it "calls create_notification with sender" do
      expect(Notifications::StartedSharing).to receive(:create_notification).with(
        alice, bob.person, bob.person
      ).and_return(started_sharing_notification)

      Notifications::StartedSharing.notify(contact, [])
    end

    it "sends an email to the contacted user" do
      allow(Notifications::StartedSharing).to receive(:create_notification).and_return(started_sharing_notification)
      expect(alice).to receive(:mail).with(Workers::Mail::StartedSharing, alice.id, bob.person.id, bob.person.id)

      Notifications::StartedSharing.notify(contact, [])
    end

    it "does not notify if the sender of the contact is ignored" do
      alice.blocks.create(person: contact.person)

      expect_any_instance_of(Notifications::StartedSharing).not_to receive(:email_the_user)

      Notifications::StartedSharing.notify(contact, [])

      expect(Notifications::StartedSharing.where(target: bob.person)).not_to exist
    end
  end
end
