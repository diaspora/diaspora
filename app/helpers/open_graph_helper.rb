module OpenGraphHelper
  def og_title(post)
    meta_tag_with_property('og:title', post_page_title(post, :length => 140))
  end

  def og_type(post)
    meta_tag_with_property('og:type', 'article')
  end

  def og_url(post)
    meta_tag_with_property('og:url', post_url(post))
  end

  def og_image(post)
    tags = post.photos.map{|x| meta_tag_with_property('og:image', x.url(:thumb_small))}
    tags << meta_tag_with_property('og:image',  "#{root_url.chop}#{image_path('asterisk.png')}") if tags.empty?
    tags.join(' ')
  end

  def og_site_name
    meta_tag_with_property('og:site_name', 'Diaspora*')
  end

  def og_description(post)
    meta_tag_with_property('og:description', post_page_title(post, :length => 1000))
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