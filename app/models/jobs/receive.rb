#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  class Receive
    extend ResqueJobLogging
    @queue = :receive
    def self.perform(user_id, xml, salmon_author_id)
      user = User.find(user_id)
      salmon_author = Person.find(salmon_author_id)
      user.receive(xml, salmon_author)
    end
  end
end
