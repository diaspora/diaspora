# frozen_string_literal: true

describe Notifications::ContactsBirthdayService do
  let(:contact) { alice.contact_for(bob.person) }
  let(:recipient) { alice }
  let(:actor) { bob.person }

  describe ".notify" do
    it "calls create_notification with contact owner as a recipient" do
      expect(Notifications::ContactsBirthday).to receive(:create_notification).with(recipient, actor, actor)

      Notifications::ContactsBirthdayService.notify(contact)
    end

    it "sends an email to the contacts owner person" do
      expect(Mail::ContactsBirthdayWorker).to receive(:perform_async).with(recipient.id, actor.id, actor.id)

      Notifications::ContactsBirthdayService.notify(contact)
    end

    context "when user disabled in app notification" do
      before do
        alice.notification_settings.create(
          type:           "contacts_birthday",
          email_enabled:  true,
          in_app_enabled: false
        )
      end

      it "does not create a notification but still sends the email" do
        expect(Mail::ContactsBirthdayWorker).to receive(:perform_async).with(recipient.id, actor.id, actor.id)

        Notifications::ContactsBirthdayService.notify(contact)

        expect(Notifications::ContactsBirthday.where(target: bob.person)).not_to exist
      end
    end
  end
end
