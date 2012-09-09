module MobileHelper
  def aspect_select_options(aspects, selected)
    selected_id = selected == :all ? "" : selected.id
    '<option value="" >All</option>\n'.html_safe + options_from_collection_for_select(aspects, "id", "name", selected_id)
  end

  def mobile_reshare_icon(post)
    if (post.public? || reshare?(post)) && (user_signed_in? && post.author != current_user.person)
      root = reshare?(post) ? post.root : post

      if root.author != current_user.person_id
        reshare = Reshare.where(:author_id => current_user.person_id,
                                :root_guid => root.guid).first
        klass = reshare.present? ? "active" : "inactive"
        link_to '', reshares_path(:root_guid => root.guid), :title => t('reshares.reshare.reshare_confirmation', :author => root.author_name), :class => "image_link reshare_action #{klass}"
      end
    end
  end

  def mobile_like_icon(post)
    if current_user && current_user.liked?(post)
      link_to '', post_like_path(post.id, current_user.like_for(post).id), :class => "image_link like_action active"
    else
      link_to '', post_likes_path(post.id), :class => "image_link like_action inactive"
    end
  end

  def mobile_comment_icon(post)
    link_to '', new_post_comment_path(post), :class => "image_link comment_action inactive"
  end

  def reactions_link(post)
    reactions_count = post.comments_count + post.likes_count
    if reactions_count > 0
      link_to "#{t('reactions', :count => reactions_count)}", post_comments_path(post, :format => "mobile"), :class => 'show_comments'
    else
      html = "<span class='show_comments'>"
      html << "#{t('reactions', :count => reactions_count)}"
      html << "</span>"
    end
  end
end
