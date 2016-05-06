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
    logger.info "receiving local batch for #{@object.inspect}"
    if @object.respond_to?(:relayable?)
      receive_relayable
    else
      create_share_visibilities
    end

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

  private

  def needs_notification?(person)
    person && person != @object.author.owner && !@users.exists?(person.id)
  end
end
