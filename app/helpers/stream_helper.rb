#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module StreamHelper
  GSUB_THIS = "FIUSDHVIUSHDVIUBAIUHAPOIUXJM"
  def comment_toggle(count, commenting_disabled=false)
    if count <= 3
      link_to "#{t('stream_helper.hide_comments')} (#{count})", '#', :class => "show_post_comments"
    else
      link_to "#{t('stream_helper.show_comments')} (#{count})", '#', :class => "show_post_comments"
    end
  end

  def new_comment_form(post_id, current_user)
    @form ||= controller.render_to_string(
      :partial => 'comments/new_comment', :locals => {:post_id => GSUB_THIS, :current_user => current_user})
    @form.gsub(GSUB_THIS, post_id.to_s)
  end
end
