#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Postzord::Receiver::LocalBatch < Postzord::Receiver

  attr_reader :object, :recipient_user_ids, :users

  def initialize(object, recipient_user_ids)
    @object = object
    @recipient_user_ids = recipient_user_ids
    @users = User.where(:id => @recipient_user_ids)

  end

  def receive!
    FEDERATION_LOGGER.info("receiving local batch for #{@object.inspect}")
    if @object.respond_to?(:relayable?)
      receive_relayable
    else
      create_share_visibilities
    end
    notify_mentioned_users if @object.respond_to?(:mentions)

    # 09/27/11 this is slow
    notify_users

    FEDERATION_LOGGER.info("receiving local batch completed for #{@object.inspect}")
    true
  end

  # NOTE(copied over from receiver public)
  # @return [Object]
  def receive_relayable
    if @object.parent_author.local?
      # receive relayable object only for the owner of the parent object
      @object.receive(@object.parent_author.owner)
    end
    @object
  end

  # Batch import post visibilities for the recipients of the given @object
  # @note performs a bulk insert into mySQL
  # @return [void]
  def create_share_visibilities
    contacts_ids = Contact.connection.select_values(Contact.where(:user_id => @recipient_user_ids, :person_id => @object.author_id).select("id").to_sql)
    ShareVisibility.batch_import(contacts_ids, object)
  end

  # Notify any mentioned users within the @object's text
  # @return [void]
  def notify_mentioned_users
    @object.mentions.each do |mention|
      mention.notify_recipient
    end
  end

  #NOTE(these methods should be in their own module, included in this class)
  # Notify users of the new object
  # return [void]
  def notify_users
    return unless @object.respond_to?(:notification_type)
    @users.each do |user|
      Notification.notify(user, @object, @object.author)
    end
  end
end
