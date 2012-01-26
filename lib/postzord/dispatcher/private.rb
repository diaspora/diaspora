#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Postzord::Dispatcher::Private < Postzord::Dispatcher

  # @param user [User]
  # @param activity [String]
  # @return [Salmon::EncryptedSlap]
  def self.salmon(user, activity)
    Salmon::EncryptedSlap.create_by_user_and_activity(user, activity)
  end

  # @param person [Person]
  # @return [String]
  def self.receive_url_for(person)
    person.receive_url
  end
end
