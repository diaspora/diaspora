#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Like < Federated::Relayable
  class Generator < Federated::Generator
    def self.federated_class
      Like
    end

    def relayable_options
      {:target => @target, :positive => true}
    end
  end

  after_create do
    self.parent.update_likes_counter
  end

  after_destroy do
    self.parent.update_likes_counter
  end

  xml_attr :positive

  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :guid
    t.add :author
    t.add :created_at
  end

  def notification_type(user, person)
    #TODO(dan) need to have a notification for likes on comments, until then, return nil
    return nil if self.target_type == "Comment"
    Notifications::Liked if self.target.author == user.person && user.person != person
  end
end
