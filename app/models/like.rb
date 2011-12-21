#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Like < ActiveRecord::Base
  include ROXML

  include Diaspora::Webhooks
  include Diaspora::Guid

  xml_attr :target_type
  include Diaspora::Relayable

  xml_attr :positive
  xml_attr :diaspora_handle

  belongs_to :target, :polymorphic => true
  belongs_to :author, :class_name => 'Person'

  validates_uniqueness_of :target_id, :scope => [:target_type, :author_id]
  validates :parent, :presence => true #should be in relayable (pending on fixing Message)

  after_create do
    self.parent.update_likes_counter
  end

  after_destroy do
    self.parent.update_likes_counter
  end

  def diaspora_handle
    self.author.diaspora_handle
  end

  def diaspora_handle= nh
    self.author = Webfinger.new(nh).fetch
  end

  def parent_class
    self.target_type.constantize
  end

  def parent
    self.target
  end

  def parent= parent
    self.target = parent
  end

  def notification_type(user, person)
    #TODO(dan) need to have a notification for likes on comments, until then, return nil
    return nil if self.target_type == "Comment"
    Notifications::Liked if self.target.author == user.person && user.person != person
  end
end
