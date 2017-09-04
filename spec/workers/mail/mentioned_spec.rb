# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Workers::Mail::Mentioned do
  describe "#perform" do
    it "should call .deliver on the notifier object" do
      user = alice
      sm = FactoryGirl.build(:status_message)
      m = Mention.new(person: user.person, mentions_container: sm)

      mail_double = double()
      expect(mail_double).to receive(:deliver_now)
      expect(Notifier).to receive(:send_notification)
        .with("mentioned", user.id, sm.author.id, m.id).and_return(mail_double)

      Workers::Mail::Mentioned.new.perform(user.id, sm.author.id, m.id)
    end
  end
end
