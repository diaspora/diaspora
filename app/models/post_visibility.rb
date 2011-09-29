#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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
  def self.batch_import(contact_ids, post)
    if postgres?
      contact_ids.each do |contact_id|
        PostVisibility.find_or_create_by_contact_id_and_post_id(contact_id, post.id)
      end
    else
       new_post_visibilities_data = contact_ids.map do |contact_id|
        [contact_id, post.id]
      end
      PostVisibility.import([:contact_id, :post_id], new_post_visibilities_data)
    end
  end
end
