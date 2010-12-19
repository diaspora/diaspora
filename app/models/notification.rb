#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class Notification < ActiveRecord::Base

  belongs_to :receiver, :class_name => 'User'
  belongs_to :actor, :class_name => 'Person'
  belongs_to :target, :polymorphic => true

  def self.for(receiver, opts={})
    self.where(opts.merge!(:receiver => receiver)).order('created_at desc')
  end

  def self.notify(receiver, target, actor)
    if target.respond_to? :notification_type
      if action = target.notification_type(receiver, actor)
        create(:target => target,
               :action => action,
               :actor => actor,
               :receiver => receiver)
       end
    end
  end
end
