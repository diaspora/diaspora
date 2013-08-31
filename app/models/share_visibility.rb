#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ShareVisibility < ActiveRecord::Base
  belongs_to :contact
  belongs_to :shareable, :polymorphic => :true

  scope :for_a_users_contacts, lambda { |user|
    where(:contact_id => user.contacts.map {|c| c.id})
  }
  scope :for_contacts_of_a_person, lambda { |person|
    where(:contact_id => person.contacts.map {|c| c.id})
  }

  validate :not_public

  # Perform a batch import, given a set of contacts and a shareable
  # @note performs a bulk insert in mySQL; performs linear insertions in postgres
  # @param contacts [Array<Contact>] Recipients
  # @param share [Shareable]
  # @return [void]
  def self.batch_import(contact_ids, share)
    return false unless ShareVisibility.new(:shareable_id => share.id, :shareable_type => share.class.to_s).valid?

    if AppConfig.postgres?
      contact_ids.each do |contact_id|
        ShareVisibility.find_or_create_by(
          contact_id: contact_id,
          shareable_id: share.id,
          shareable_type: share.class.base_class.to_s
        )
      end
    else
       new_share_visibilities_data = contact_ids.map do |contact_id|
        [contact_id, share.id, share.class.base_class.to_s]
      end
      ShareVisibility.import([:contact_id, :shareable_id, :shareable_type], new_share_visibilities_data)
    end
  end

  private
  def not_public
    if shareable.public?
      errors[:base] << "Cannot create visibility for a public object"
    end
  end
end
