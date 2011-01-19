#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Job
  class NotifyLocalUsers < Base
    @queue = :receive_local

    require File.join(Rails.root, 'app/models/notification')

    def self.perform_delegate(user_id, object_klass, object_id, person_id)
      user  = User.find_by_id(user_id)
      object = object_klass.constantize.find_by_id(object_id)
      person = Person.find_by_id(person_id)

      Notification.notify(user, object, person)
    end
  end
end
