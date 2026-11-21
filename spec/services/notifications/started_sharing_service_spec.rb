# frozen_string_literal: true

describe Notifications::StartedSharingService do
  let(:contact) { alice.contact_for(bob.person) }
  let(:started_sharing_notification) { Notifications::StartedSharing.new(recipient: alice) }

  describe ".notify" do
    it "calls create_notification with sender" do
      expect(Notifications::StartedSharing).to receive(:create_notification).with(
        alice, bob.person, bob.person
      ).and_return(started_sharing_notification)

      Notifications::StartedSharingService.notify(contact, [])
    end

    it "sends an email to the contacted user" do
      expect(Mail::StartedSharingWorker).to receive(:perform_async).with(alice.id, bob.person.id, bob.person.id)

      Notifications::StartedSharingService.notify(contact, [])
    end

    it "does not create a notification if the sender of the contact is ignored" do
      alice.blocks.create(person: contact.person)

      Notifications::StartedSharingService.notify(contact, [])

      expect(Notifications::StartedSharing.where(target: bob.person)).not_to exist
    end

    context "when user disabled in app notification" do
      before do
        alice.notification_settings.create(
          type:           "started_sharing",
          email_enabled:  true,
          in_app_enabled: false
        )
      end

      it "does not create a notification but still sends the email" do
        expect(Mail::StartedSharingWorker).to receive(:perform_async).with(alice.id, bob.person.id, bob.person.id)

        Notifications::StartedSharingService.notify(contact, [])

        expect(Notifications::StartedSharing.where(target: bob.person)).not_to exist
      end
    end
  end
end
