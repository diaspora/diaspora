#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module UsersHelper
  def first_name_or_username (user)
    set_name = user.person.profile.first_name
    (set_name.nil? || set_name.empty?) ? user.username : user.person.profile.first_name 
  end
end
