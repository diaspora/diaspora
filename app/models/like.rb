#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Like < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include ROXML

  include Diaspora::Webhooks
  include Diaspora::Guid

  xml_attr :target_type
  include Diaspora::Relayable

  include Diaspora::Socketable

  xml_attr :positive
  xml_attr :diaspora_handle

  belongs_to :target, :polymorphic => true #, :counter_cache => true
  belongs_to :author, :class_name => 'Person'

  validates_uniqueness_of :target_id, :scope => [:target_type, :author_id]
  validates_presence_of :author, :target

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
    Notifications::Liked if self.target.author == user.person && user.person != person
  end
end
