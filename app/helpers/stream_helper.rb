#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module StreamHelper

  def comment_toggle(count)
    if count > 0
      link_to "#{t('stream_helper.hide_comments')} (#{count})", '#', :class => "show_post_comments"
    else
      link_to "#{t('stream_helper.show_comments')} (#{count})", '#', :class => "show_post_comments"
    end
  end

end
