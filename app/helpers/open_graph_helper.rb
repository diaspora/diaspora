module OpenGraphHelper
  def og_title(title)
    meta_tag_with_property('og:title', title)
  end

  def og_type(post)
    meta_tag_with_property('og:type', 'article')
  end

  def og_url(url)
    meta_tag_with_property('og:url', url)
  end

  def og_image(post=nil)
    tags = []
    tags = post.photos.map{|x| meta_tag_with_property('og:image', x.url(:thumb_large))} if post
    tags << meta_tag_with_property('og:image', default_image_url) if tags.empty?
    tags.join(' ')
  end

  def og_description(description)
    meta_tag_with_property('og:description', description)
  end

  def og_type(type='website')
    meta_tag_with_property('og:type', type)
  end

  def og_namespace
    AppConfig.services.facebook.open_graph_namespace
  end

  def og_site_name
    meta_tag_with_property('og:site_name', AppConfig.settings.pod_name)
  end

  def og_common_tags
    [og_site_name]
  end

  def og_general_tags
    [
      *og_common_tags,
      og_type,
      og_title('diaspora* social network'),
      og_image,
      og_url(AppConfig.environment.url),
      og_description('diaspora* is the online social world where you are in control.')
    ].join("\n").html_safe
  end

  def og_page_post_tags(post)
    tags = og_common_tags

    
    if post.message
      tags.concat [
        *tags,
        og_type("#{og_namespace}:frame"),
        og_title(post_page_title(post, :length => 140)),
        og_url(post_url(post)),
        og_image(post),
        og_description(post.message.plain_text_without_markdown truncate: 1000)
      ]
    end
    
    tags.join("\n").html_safe
  end

  def og_prefix
    "og: http://ogp.me/ns# #{og_namespace}: https://diasporafoundation.org/ns/joindiaspora#"
  end

  def meta_tag_with_property(name, content)
    tag(:meta, :property => name, :content => content)
  end

  def og_html(cache)
    "<a href=\"#{cache.url}\" target=\"_blank\">" +
    "  <div>" +
    "    <img src=\"#{cache.image}\" />" +
    "    <strong>#{cache.title}</strong>" +
    "    <p>#{truncate(cache.description, length: 250, separator: ' ')}</p>" +
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
