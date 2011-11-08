#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module TagsHelper
  def tag_page_link(tag)
    link_to("##{tag}", tag_path(:name => tag))
  end
end
