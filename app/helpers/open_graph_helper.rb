# frozen_string_literal: true

module OpenGraphHelper
  def link_to_oembed_image(cache, prefix = 'thumbnail_')
    link_to(oembed_image_tag(cache, prefix), cache.url, :target => '_blank')
  end

  def oembed_image_tag(cache, prefix)
    image_tag(cache.data["#{prefix}url"], cache.options_hash(prefix))
  end
end
