#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class ReceiveLocalBatch < Base
    require File.join(Rails.root, 'lib/postzord/receiver')

    @queue = :receive
    def self.perform(post_id, recipient_user_ids)
      post = Post.find(post_id)
      create_visibilities(post, recipient_user_ids)
      socket_to_users(post, recipient_user_ids) if post.respond_to?(:socket_to_user)
      notify_mentioned_users(post)
    end
    def self.create_visibilities(post, recipient_user_ids)
      contacts = Contact.where(:user_id => recipient_user_ids, :person_id => post.author_id)
      new_post_visibilities = contacts.map do |contact|
        PostVisibility.new(:contact_id => contact.id, :post_id => post.id)
      end
      PostVisibility.import new_post_visibilities
    end
    def self.socket_to_users(post, recipient_user_ids)
      recipient_user_ids.each do |id|
        post.socket_to_user(id)
      end
    end
    def self.notify_mentioned_users(post)
      post.mentions.each do |mention|
        mention.notify_recipient
      end
    end
  end
end
