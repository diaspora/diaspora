#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module CommentsHelper
  GSUB_THIS = "FIUSDHVIUSHDVIUBAIUHAPOIUXJM"
  def comment_toggle(post, commenting_disabled=false)
    if post.comments.size <= 3
      str = link_to "#{t('stream_helper.hide_comments')}", post_comments_path(post.id), :class => "toggle_post_comments"
    else
      str = link_to "#{t('stream_helper.show_more_comments', :number => post.comments.size - 3)}", post_comments_path(post.id), :class => "toggle_post_comments"
    end
    str
  end

  # This method memoizes the new comment form in order to avoid the overhead of rendering it on every post.
  # @param [Integer] post_id The id of the post that this form should post to.
  # @param [User] current_user
  # @return [String] The HTML for the new comment form.
  def new_comment_form(post_id, current_user)
    @form ||= controller.render_to_string(
      :partial => 'comments/new_comment', :locals => {:post_id => GSUB_THIS, :current_user => current_user})
    @form.gsub(GSUB_THIS, post_id.to_s).html_safe
  end

  def comment_form_wrapper_class(post)
    if post.comments.empty? && request && request.format != 'mobile'
      'hidden'
    else
      nil
    end
  end
end
