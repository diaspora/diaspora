#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class ReceiveLocal < Base
    require File.join(Rails.root, 'lib/postzord/receiver')

    @queue = :receive_local
    def self.perform_delegate(user_id, person_id, object_type, object_id)
      user = User.find(user_id)
      person = Person.find(person_id)
      object = object_type.constantize.where(:id => object_id).first

      z = Postzord::Receiver.new(user, :person => person, :object => object)
      z.receive_object
    end
  end
end
