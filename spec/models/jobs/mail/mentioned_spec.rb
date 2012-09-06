#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Jobs::Mail::Mentioned do
  describe '#perfom' do
    it 'should call .deliver on the notifier object' do
      user = alice
      sm = FactoryGirl.build(:status_message)
      m = Mention.new(:person => user.person, :post=> sm)

      mail_mock = mock()
      mail_mock.should_receive(:deliver)
      Notifier.should_receive(:mentioned).with(user.id, sm.author.id, m.id).and_return(mail_mock)

      Jobs::Mail::Mentioned.perform(user.id, sm.author.id, m.id)
    end
  end
end
