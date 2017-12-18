# frozen_string_literal: true

describe Workers::Mail::ContactsBirthday do
  describe "#perform" do
    it "should call .deliver on the notifier object" do
      mail_double = double
      expect(mail_double).to receive(:deliver_now)
      expect(Notifier).to receive(:send_notification)
        .with("contacts_birthday", alice.id).and_return(mail_double)
      Workers::Mail::ContactsBirthday.new.perform(alice.id)
    end
  end
end
