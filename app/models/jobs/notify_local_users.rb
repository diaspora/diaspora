#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Job
  class NotifyLocalUsers < Base
    @queue = :receive_local

    require File.join(Rails.root, 'app/models/notification')

    def self.perform_delegate(user_ids, object_klass, object_id, person_id)
      users = User.where(:id => user_ids)
      object = object_klass.constantize.find_by_id(object_id)
      person = Person.find_by_id(person_id)

      users.each{|user| Notification.notify(user, object, person) }
    end
  end
end
