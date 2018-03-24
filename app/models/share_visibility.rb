# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ShareVisibility < ApplicationRecord
  belongs_to :user
  belongs_to :shareable, polymorphic: :true

  scope :for_a_user, ->(user) {
    where(user_id: user.id)
  }

  scope :for_shareable, ->(shareable) {
    where(shareable_id: shareable.id, shareable_type: shareable.class.base_class.to_s)
  }

  validate :not_public

  # Perform a batch import, given a set of users and a shareable
  # @note performs a bulk insert in mySQL; performs linear insertions in postgres
  # @param user_ids [Array<Integer>] Recipients
  # @param share [Shareable]
  # @return [void]
  def self.batch_import(user_ids, share)
    return false if share.public?

    user_ids -= ShareVisibility.for_shareable(share).where(user_id: user_ids).pluck(:user_id)
    return false if user_ids.empty?

    create_visilities(user_ids, share)
  end

  private

  private_class_method def self.create_visilities(user_ids, share)
    if AppConfig.postgres?
      user_ids.each do |user_id|
        ShareVisibility.find_or_create_by(
          user_id:        user_id,
          shareable_id:   share.id,
          shareable_type: share.class.base_class.to_s
        )
      end
    else
      new_share_visibilities_data = user_ids.map do |user_id|
        [user_id, share.id, share.class.base_class.to_s]
      end
      ShareVisibility.import(%i(user_id shareable_id shareable_type), new_share_visibilities_data)
    end
  end

  def not_public
    errors[:base] << "Cannot create visibility for a public object" if shareable.public?
  end
end
