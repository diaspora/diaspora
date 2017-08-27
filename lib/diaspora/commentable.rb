# frozen_string_literal: true

#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Commentable
    def self.included(model)
      model.instance_eval do
        has_many :comments, :as => :commentable, :dependent => :destroy
      end
    end

    # @return [Array<Comment>]
  def last_three_comments
    return [] if self.comments_count == 0
    # DO NOT USE .last(3) HERE.  IT WILL FETCH ALL COMMENTS AND RETURN THE LAST THREE
    # INSTEAD OF DOING THE FOLLOWING, AS EXPECTED (THX AR):
    self.comments.order('created_at DESC').limit(3).includes(:author => :profile).reverse
  end

    # @return [Integer]
    def update_comments_counter
      self.class.where(:id => self.id).
        update_all(:comments_count => self.comments.count)
    end

    def comments_authors
      Person.where(id: comments.select(:author_id).distinct)
    end
  end
end
