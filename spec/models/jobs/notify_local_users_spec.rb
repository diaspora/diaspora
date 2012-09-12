#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Jobs::NotifyLocalUsers do
  describe '#perfom' do
    it 'should call Notification.notify for each participant user' do
      person = FactoryGirl.create :person
      post = FactoryGirl.create :status_message

      StatusMessage.should_receive(:find_by_id).with(post.id).and_return(post)
      #User.should_receive(:where).and_return([alice, eve])
      Notification.should_receive(:notify).with(instance_of(User), instance_of(StatusMessage), instance_of(Person)).twice

      Jobs::NotifyLocalUsers.perform([alice.id, eve.id], post.class.to_s, post.id, person.id)
    end
  end
end
