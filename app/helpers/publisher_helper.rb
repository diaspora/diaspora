#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PublisherHelper
  def remote?
    params[:controller] != "tags"
  end

  def all_aspects_selected?(selected_aspects)
    @all_aspects_selected ||= all_aspects.size == selected_aspects.size
  end
end
