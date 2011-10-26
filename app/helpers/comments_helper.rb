#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module CommentsHelper
  GSUB_THIS = "FIUSDHVIUSHDVIUBAIUHAPOIUXJM"
  def comment_toggle(post, commenting_disabled=false)
    if post.comments.size <= 3
      link_to "#{t('stream_helper.hide_comments')}", post_comments_path(post.id), :class => "toggle_post_comments"
    elsif ! user_signed_in?
      link_to "#{t('stream_helper.show_more_comments', :number => post.comments.size - 3)}", post_path(post.id, :all_comments => '1'), :class => "toggle_post_comments"
    else
      link_to "#{t('stream_helper.show_more_comments', :number => post.comments.size - 3)}", post_comments_path(post.id), :class => "toggle_post_comments"
    end
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

  def commenting_disabled?(post)
    return true unless user_signed_in?
    if defined?(@commenting_disabled)
      @commenting_disabled
    elsif defined?(@stream)
      !@stream.can_comment?(post)
    else
      false
    end
  end

  def all_comments?
    !! params['all_comments']
  end
end
