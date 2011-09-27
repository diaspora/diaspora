#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Postzord::Dispatcher::Public < Postzord::Dispatcher

  # @param user [User] User dispatching the object in question
  # @param object [Object] The object to be sent to other Diaspora installations
  # @opt additional_subscribers [Array<Person>] Additional subscribers
  def initialize(user, object, opts={})
    @sender = user
    @object = object
    @xml = @object.to_diaspora_xml

    additional_subscribers = opts[:additional_subscribers] || []
    @subscribers = subscribers_from_object | [*additional_subscribers]
  end

  # @param user [User]
  # @param activity [String]
  # @return [Salmon::EncryptedSlap]
  def self.salmon(user, activity)
    Salmon::Slap.create_by_user_and_activity(user, activity)
  end

  # @param person [Person]
  # @return [String]
  def self.receive_url_for(person)
    person.url + 'receive/public'
  end
end
