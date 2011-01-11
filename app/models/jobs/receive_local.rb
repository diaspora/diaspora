#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  class ReceiveLocal
    require File.join(Rails.root, 'lib/postzord/receiver')

    extend ResqueJobLogging
    @queue = :receive_local
    def self.perform(user_id, person_id, object_type, object_id)
      user = User.find(user_id)
      person = Person.find(person_id)
      object = object_type.constantize.first(:id => object_id)

      z = Postzord::Receiver.new(user, :person => person, :object => object)
      z.receive_object
    end
  end
end
