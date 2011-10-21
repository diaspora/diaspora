#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Api::V0::Serializers::Tag

  def initialize(tag)
    @stream = Stream::Tag.new(nil, tag)
  end

  def as_json(opts={})
    {
      "name" => @stream.tag_name,
      "person_count" => @stream.tagged_people_count,
      "followed_count" => @stream.tag_follow_count,
      "posts" => []
    }
  end
end
