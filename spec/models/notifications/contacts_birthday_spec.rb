# frozen_string_literal: true

describe Notifications::ContactsBirthday, type: :model do
  let(:contact) { alice.contact_for(bob.person) }
  let(:recipient) { alice }
  let(:actor) { bob.person }
  let(:birthday_notification) { Notifications::ContactsBirthday.new(recipient: alice) }

  describe ".notify" do
    it "calls create_notification with contact owner as a recipient" do
      expect(Notifications::ContactsBirthday).to receive(:create_notification).with(recipient, actor, actor)

      Notifications::ContactsBirthday.notify(contact, [])
    end

    it "sends an email to the contacts owner person" do
      allow(Notifications::ContactsBirthday).to receive(:create_notification).and_return(birthday_notification)
      expect(alice).to receive(:mail).with(Workers::Mail::ContactsBirthday, recipient.id, actor.id, actor.id)

      Notifications::ContactsBirthday.notify(contact, [])
    end

    it "does not notify if the sender of the contact is ignored" do
      alice.blocks.create(person: contact.person)

      expect_any_instance_of(Notifications::ContactsBirthday).not_to receive(:email_the_user)

      Notifications::ContactsBirthday.notify(contact, [])

      expect(Notifications::ContactsBirthday.where(target: bob.person)).not_to exist
    end

    context "when user disabled in app notification" do
      before do
        alice.user_preferences.create(
          email_type:     "contacts_birthday",
          in_app_enabled: false
        )
      end

      it "does not notify" do
        expect_any_instance_of(Notifications::ContactsBirthday).not_to receive(:email_the_user)

        Notifications::ContactsBirthday.notify(contact, [])

        expect(Notifications::ContactsBirthday.where(target: bob.person)).not_to exist
      end
    end
  end
end
