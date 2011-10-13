#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Commentable
    def self.included(model)
      model.instance_eval do
        has_many :comments, :as => :commentable, :order => 'created_at', :dependent => :destroy
      end
    end

    # @return [Array<Comment>]
    def last_three_comments
      self.comments.order('created_at DESC').limit(3).includes(:author => :profile).reverse
    end

    # @return [Integer]
    def update_comments_counter
      self.class.where(:id => self.id).
        update_all(:comments_count => self.comments.count)
    end

  end
end
