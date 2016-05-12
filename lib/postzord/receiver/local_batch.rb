#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Postzord::Receiver::LocalBatch < Postzord::Receiver

  attr_reader :object, :recipient_user_ids

  def author
    @author || object.author
  end

  def users
    @users ||= User.where(id: @recipient_user_ids)
  end

  def initialize(object, recipient_user_ids, author=nil)
    @author = author
    @object = object
    @recipient_user_ids = recipient_user_ids
  end

  def receive!
    logger.info "receiving local batch for #{@object.inspect}"
    if @object.respond_to?(:relayable?)
      receive_relayable
    else
      create_share_visibilities
    end

    # 09/27/11 this is slow
    notify_users

    logger.info "receiving local batch completed for #{@object.inspect}"
  end

  # NOTE(copied over from receiver public)
  # @return [void]
  def receive_relayable
    if @object.parent_author.local?
      # receive relayable object only for the owner of the parent object
      @object.receive(@object.parent_author.owner)
    end
  end

  # Batch import post visibilities for the recipients of the given @object
  # @note performs a bulk insert into mySQL
  # @return [void]
  def create_share_visibilities
    ShareVisibility.batch_import(@recipient_user_ids, object)
  end

  # Notify any mentioned users within the @object's text
  # @return [void]
  def notify_mentioned_users
    users.find_each do |user|
      user.notify_if_mentioned(@object)
    end
  end

  #NOTE(these methods should be in their own module, included in this class)
  # Notify users of the new object
  # return [void]
  def notify_users
    notify_mentioned_users if @object.respond_to?(:mentions)

    return unless @object.respond_to?(:notification_type)
    users.find_each do |user|
      Notification.notify(user, @object, author)
    end
  end
end
