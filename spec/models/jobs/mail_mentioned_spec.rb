#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Job::MailMentioned do
  describe '#perfom_delegate' do
    it 'should call .deliver on the notifier object' do
      user = alice
      sm =  Factory(:status_message)
      m  = Mention.new(:person => user.person, :post=> sm)

      Notification.notify(user, m, sm.person)
    end
  end
end
