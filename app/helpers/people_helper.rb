#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


module PeopleHelper

  def search_or_index
    if params[:q]
      " results for #{params[:q]}"
    else
      " people on pod is aware of"
    end

  end
end
