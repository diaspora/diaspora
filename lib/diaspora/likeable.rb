#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Likeable
    def self.included(model)
      model.instance_eval do
        has_many :likes, :conditions => {:positive => true}, :dependent => :delete_all, :as => :target
        has_many :dislikes, :conditions => {:positive => false}, :class_name => 'Like', :dependent => :delete_all, :as => :target
      end
    end

    # @return [Integer]
    def update_likes_counter
      self.likes_count = self.likes.count
      self.save
    end
  end
end
