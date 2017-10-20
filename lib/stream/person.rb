# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::Person < Stream::Base

  attr_accessor :person

  def initialize(user, person, opts={})
    self.person = person
    super(user, opts)
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= user.present? ? user.posts_from(@person) : @person.posts.where(:public => true)
  end

  # @return [Array<Post>]
  def stream_posts
    posts.for_a_stream(max_time, order, user, true).tap do |posts|
      like_posts_for_stream!(posts) # some sql person could probably do this with joins.
    end
  end
end
