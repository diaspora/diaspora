#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module TagsHelper
  def next_page_path
    tag_path(@tag, :max_time => @posts.last.created_at.to_i, :class => 'paginate')
  end
end
