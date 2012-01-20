#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::Place < Stream::Base

  attr_accessor :place

  def initialize(user, place, opts={})
    self.place = place
    super(user, opts)
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= Post.all
  end
end

