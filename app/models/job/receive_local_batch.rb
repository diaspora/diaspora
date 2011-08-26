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
      notify_users(post, recipient_user_ids)
    end

    def self.create_visibilities(post, recipient_user_ids)
      contacts = Contact.where(:user_id => recipient_user_ids, :person_id => post.author_id)
      
      if postgres?
        # Take the naive approach to inserting our new visibilities for now.
        contacts.each do |contact|
          PostVisibility.find_or_create_by_contact_id_and_post_id(contact.id, post.id)
        end
      else
        # Use a batch insert on mySQL.
        new_post_visibilities = contacts.map do |contact|
          PostVisibility.new(:contact_id => contact.id, :post_id => post.id)
        end
        PostVisibility.import(new_post_visibilities)
      end

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

    def self.notify_users(post,  recipient_user_ids)
      if post.respond_to?(:notification_type) 
        recipient_user_ids.each{|id|
          Notification.notify(User.find(id), post, post.author)
        }
      end
    end
  end
end
