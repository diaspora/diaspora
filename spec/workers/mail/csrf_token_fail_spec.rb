# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Workers::Mail::CsrfTokenFail do
  describe "#perform" do
    it "should call .deliver on the notifier object" do
      user = alice
      mail_double = double
      expect(mail_double).to receive(:deliver_now)
      expect(Notifier).to receive(:send_notification).with("csrf_token_fail", user.id).and_return(mail_double)

      Workers::Mail::CsrfTokenFail.new.perform(user.id)
    end
  end
end
