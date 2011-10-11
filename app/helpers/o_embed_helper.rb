module OEmbedHelper
  def o_embed_html(cache)
    data = cache.data
    title = data.fetch('title', 'an awesome post')
    html ||= link_to(title, cache.url, :target => '_blank') 
    return nil unless data.has_key?('type')
    case data['type']
    when 'video', 'rich'
      if cache.is_trusted_and_has_html?
        html = data['html']
      elsif data.has_key?('thumbnail_url')
        html = link_to_oembed_image(cache)
      end
    when 'photo'
      if data.has_key?('url')
        img_options = cache.options_hash('')
        html = link_to_oembed_image(cache, '')
      end
    else
    end

    return html.html_safe
  end

  def link_to_oembed_image(cache, prefix = 'thumbnail_')
    link_to(oembed_image_tag(cache, prefix), cache.url, :target => '_blank')
  end
  
  def oembed_image_tag(cache, prefix)
    image_tag(cache.data[prefix + 'url'], cache.image_options_hash(prefix))
  end
end
