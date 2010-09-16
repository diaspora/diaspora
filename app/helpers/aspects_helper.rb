#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


module AspectsHelper
  def link_for_aspect( aspect )
    link_to aspect.name, aspect
  end

  def remove_link( aspect )
    if aspect.people.size == 0
      link_to "remove", aspect, :method => :delete
    else
      "<span class='grey' title='Aspect not empty'>remove</span>"
    end
  end
end
