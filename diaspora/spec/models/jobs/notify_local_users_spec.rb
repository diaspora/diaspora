#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Job::NotifyLocalUsers do
  describe '#perfom' do
    it 'should call Notification.notify for each user' do
      person = Factory :person
      object = Factory :status_message

      Notification.should_receive(:notify).with(instance_of(User), instance_of(StatusMessage), instance_of(Person)).twice
      Job::NotifyLocalUsers.perform([alice.id, eve.id], object.class.to_s, object.id, person.id)
    end
  end
end
