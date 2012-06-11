#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  class NotifyLocalUsers < Base
    @queue = :receive_local

    require Rails.root.join('app', 'models', 'notification')

    def self.perform(user_ids, object_klass, object_id, person_id)

      object = object_klass.constantize.find_by_id(object_id)

      #hax
      return if (object.author.diaspora_handle == 'diasporahq@joindiaspora.com' || (object.respond_to?(:relayable?) && object.parent.author.diaspora_handle == 'diasporahq@joindiaspora.com'))
      #end hax

      users = User.where(:id => user_ids)
      person = Person.find_by_id(person_id)

      users.each{|user| Notification.notify(user, object, person) }
    end
  end
end
