#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Workers::Mail::Reshared do
  describe '#perfom' do
    it 'should call .deliver on the notifier object' do
      sm = FactoryGirl.build(:status_message, :author => bob.person, :public => true)
      reshare = FactoryGirl.build(:reshare, :author => alice.person, :root=> sm)

      mail_double = double()
      expect(mail_double).to receive(:deliver)
      expect(Notifier).to receive(:reshared).with(bob.id, reshare.author.id, reshare.id).and_return(mail_double)

      Workers::Mail::Reshared.new.perform(bob.id, reshare.author.id, reshare.id)
    end
  end
end
