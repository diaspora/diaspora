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
    tags = post.photos.map{|x| meta_tag_with_property('og:image', x.url(:thumb_large))}
    tags << meta_tag_with_property('og:image', default_image_url) if tags.empty?
    tags.join(' ')
  end

  def og_description(post)
    meta_tag_with_property('og:description', post_page_title(post, :length => 1000))
  end

  def og_type
    meta_tag_with_property('og:type', og_namespace('frame'))
  end

  def og_namespace(object)
    namespace = AppConfig.services.facebook.open_graph_namespace.present? ? AppConfig.services.facebook.open_graph_namespace : 'joindiaspora'
    "#{namespace}:frame"
  end

  def og_page_specific_tags(post)
    [og_title(post), og_type,
      og_url(post), og_image(post), 
      og_description(post)].join(' ').html_safe
  end

  def meta_tag_with_property(name, content)
    content_tag(:meta, '', :property => name, :content => content)
  end

  def og_html(cache)
    "<a href=\"#{cache.url}\" target=\"_blank\">" +
    "  <div>" +
    "    <img src=\"#{cache.image}\" />" +
    "    <strong>#{cache.title}</strong>" +
    "    <p>#{cache.description}</p>" +
    "  </div>" +
    "</a>"
  end

  def link_to_oembed_image(cache, prefix = 'thumbnail_')
    link_to(oembed_image_tag(cache, prefix), cache.url, :target => '_blank')
  end
  
  def oembed_image_tag(cache, prefix)
    image_tag(cache.data["#{prefix}url"], cache.options_hash(prefix))
  end
  private

  # This method compensates for hosting assets off of s3
  def default_image_url
    if image_path('asterisk.png').include?("http")
      image_path('asterisk.png')
    else
      "#{root_url.chop}#{image_path('asterisk.png')}"
    end
  end
end
