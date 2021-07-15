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
    def last_comments(count)
      return [] if comments_count == 0
      comments.order(:created_at).includes(author: :profile).last(count)
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
