module StreamElementHelper
  def block_user_control(author)
    if user_signed_in?
      link_to image_tag('deletelabel.png'), blocks_path(:block => {:person_id => author.id}),
        :class => 'block_button stream_element_delete',
        :confirm => t('are_you_sure'),
        :title => 'block user',
        :method => :post

    end
  end

  def delete_or_hide_button(post)
    if user_signed_in? && current_user.owns?(post)
      link_to image_tag('deletelabel.png'), post_path(post), :confirm => t('are_you_sure'), :method => :delete, :remote => true, :class => "delete stream_element_delete", :title => t('delete')
    else
      link_to image_tag('deletelabel.png'), share_visibility_path(:id => "42", :post_id => post.id), :method => :put, :remote => true, :class => "delete stream_element_delete vis_hide", :title => t('.hide_and_mute')
    end
  end
end