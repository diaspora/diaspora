#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::Place < Stream::Base

  attr_accessor :place_id 

  def initialize(user, place_id, opts={})
    self.place_id = place_id
    super(user, opts)
  end

  def place
    @place ||= ::Place.find(place_id)
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= place.posts
  end
end

