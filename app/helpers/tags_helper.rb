#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module TagsHelper
  def next_page_path
    tag_path(@tag, :max_time => @posts.last.send(session[:sort_order].to_sym).to_i)
  end
end
