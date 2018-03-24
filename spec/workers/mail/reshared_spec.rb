# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Workers::Mail::Reshared do
  describe "#perform" do
    it "should call .deliver on the notifier object" do
      sm = FactoryGirl.build(:status_message, :author => bob.person, :public => true)
      reshare = FactoryGirl.build(:reshare, :author => alice.person, :root=> sm)

      mail_double = double()
      expect(mail_double).to receive(:deliver_now)
      expect(Notifier).to receive(:send_notification)
        .with("reshared", bob.id, reshare.author.id, reshare.id).and_return(mail_double)

      Workers::Mail::Reshared.new.perform(bob.id, reshare.author.id, reshare.id)
    end
  end
end
