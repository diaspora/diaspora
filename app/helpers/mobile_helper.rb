# frozen_string_literal: true

module MobileHelper
  def mobile_reshare_icon(post)
    if (post.public? || reshare?(post)) && (user_signed_in? && post.author != current_user.person)
      absolute_root = reshare?(post) ? post.absolute_root : post

      if absolute_root && absolute_root.author != current_user.person
        reshare = Reshare.where(author_id: current_user.person_id,
                                root_guid: absolute_root.guid).first
        klass = reshare.present? ? "active" : "inactive"
        link_to content_tag(:span, post.reshares.size, class: "count reshare-count"),
                reshares_path(root_guid: absolute_root.guid),
                title: t("reshares.reshare.reshare_confirmation", author: absolute_root.author_name),
                class: "entypo-reshare reshare-action #{klass}"
      else
        content_tag :div,
                    content_tag(:span, post.reshares.size, class: "count reshare-count"),
                    class: "entypo-reshare reshare-action disabled"
      end
    else
      content_tag :div,
                  content_tag(:span, post.reshares.size, class: "count reshare-count"),
                  class: "entypo-reshare reshare-action disabled"
    end
  end

  def mobile_like_icon(post)
    if current_user && current_user.liked?(post)
      link_to content_tag(:span, post.likes.size, class: "count like-count"),
              "#",
              data:  {url: post_like_path(post.id, current_user.like_for(post).id)},
              class: "entypo-heart like-action active"
    else
      link_to content_tag(:span, post.likes.size, class: "count like-count"),
              "#",
              data:  {url: post_likes_path(post.id)},
              class: "entypo-heart like-action inactive"
    end
  end

  def mobile_comment_icon(post)
    link_to content_tag(:span, post.comments.size, class: "count comment-count"),
            new_post_comment_path(post),
            class: "entypo-comment comment-action inactive"
  end

  def show_comments_link(post, klass="")
    if klass == "active"
      entypo_class = "entypo-chevron-up"
    else
      entypo_class = "entypo-chevron-down"
    end

    link_to safe_join([
                        t("admins.stats.comments", count: post.comments_count),
                        content_tag(:i, nil, class: entypo_class)
                      ]),
            post_comments_path(post, format: "mobile"),
            class: "show-comments #{klass}"
  end

  def additional_photos
    if photo.status_message_guid?
      @additional_photos ||= photo.status_message.photos.order(:created_at)
    end
  end

  def next_photo
    @next_photo ||= additional_photos[additional_photos.index(photo)+1]
    @next_photo ||= additional_photos.first
  end

  def previous_photo
    @previous_photo ||= additional_photos[additional_photos.index(photo)-1]
  end

  def photo
    @photo ||= current_user.find_visible_shareable_by_id(Photo, params[:id])
  end
end
