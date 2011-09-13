#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PostVisibility < ActiveRecord::Base

  belongs_to :contact
  belongs_to :post

  # Perform a batch import, given a set of contacts and a post
  # @note performs a bulk insert in mySQL; performs linear insertions in postgres
  # @param contacts [Array<Contact>] Recipients
  # @param post [Post]
  # @return [void]
  def self.batch_import(contacts, post)
    if postgres?
      contacts.each do |contact|
        PostVisibility.find_or_create_by_contact_id_and_post_id(contact.id, post.id)
      end
    else
      new_post_visibilities = contacts.map do |contact|
        PostVisibility.new(:contact_id => contact.id, :post_id => post.id)
      end
      PostVisibility.import(new_post_visibilities)
    end
  end
end
