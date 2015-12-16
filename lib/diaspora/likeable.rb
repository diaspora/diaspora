#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Likeable
    def self.included(model)
      model.instance_eval do
        has_many :likes, -> { where(positive: true) }, dependent: :delete_all, as: :target
        has_many :dislikes, -> { where(positive: false) }, class_name: 'Like', dependent: :delete_all, as: :target
      end
    end

    # @return [Integer]
    def update_likes_counter
      self.class.where(id: self.id).
        update_all(likes_count: self.likes.count)
    end
  end
end
