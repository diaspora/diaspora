#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

describe Workers::Mail::CsrfTokenFail do
  describe "#perfom" do
    it "should call .deliver on the notifier object" do
      user = alice
      mail_double = double
      expect(mail_double).to receive(:deliver_now)
      expect(Notifier).to receive(:csrf_token_fail).with(user.id).and_return(mail_double)

      Workers::Mail::CsrfTokenFail.new.perform(user.id)
    end
  end
end
