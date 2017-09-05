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
  end
end
