#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Workers::NotifyLocalUsers do
  describe '#perfom' do
    it 'should call Notification.notify for each participant user' do
      post = double(id: 1234, author: double(diaspora_handle: "foo@bar"))
      klass_name = double(constantize: double(find_by_id: post))
      person = double(id: 4321)
      allow(Person).to receive(:find_by_id).and_return(person)
      expect(Notification).to receive(:notify).with(instance_of(User), post, person).twice

      Workers::NotifyLocalUsers.new.perform([alice.id, eve.id], klass_name, post.id, person.id)
    end
  end
end
