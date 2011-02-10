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

      mail_mock = mock()
      mail_mock.should_receive(:deliver)
      Notifier.should_receive(:mentioned).with(user.id, sm.person.id, m.id).and_return(mail_mock)

      Job::MailMentioned.perform_delegate(user.id, sm.person.id, m.id)
    end
  end
end
