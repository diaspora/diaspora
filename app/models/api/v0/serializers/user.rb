#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Api::V0::Serializers::User
  def initialize(user)
    @person = user.person
    @profile = @person.profile
  end

  def as_json(opts={})
    {
      "diaspora_id" => @person.diaspora_handle,
      "first_name" => @profile.first_name,
      "last_name" => @profile.last_name,
      "image_url" => @profile.image_url,
      "searchable" => @profile.searchable
    }
  end
end
