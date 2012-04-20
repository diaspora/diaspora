module OpenGraphHelper
  def og_title(post)
    meta_tag_with_property('og:title', post_page_title(post))
  end

  def og_type(post)
    meta_tag_with_property('og:type', 'article')
  end

  def og_url(post)
    meta_tag_with_property('og:url', post_url(post))
  end

  def og_image(post)
    if post.photos.present?
      img_url = post.photos.first.url(:thumb_medium)
      meta_tag_with_property('og:image', img_url)
    end
  end

  def og_site_name
    meta_tag_with_property('og:site_name', 'Diaspora*')
  end

  def og_description(post)
    meta_tag_with_property('og:description', post_page_title(post))
  end

  def og_page_specific_tags(post)
    [og_title(post), og_type(post), 
      og_url(post), og_image(post), 
      og_description(post)].join(' ').html_safe
  end

  def meta_tag_with_property(name, content)
    content_tag(:meta, '', :property => name, :content => content)
  end
end