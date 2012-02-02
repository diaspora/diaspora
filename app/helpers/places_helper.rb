module PlacesHelper

  def place_image_tag(place, size=nil)
    size ||= :thumb_small
    "<img alt=\"#{h(place.title)}\" class=\"avatar\" data-place_id=\"#{place.id}\" src=\"#{place.description.image_url(size)}\" title=\"#{h(place.title)}\">".html_safe
  end

  def place_image_link(place, opts={})
    return "" if place.nil? || place.description.nil?
    if opts[:to] == :photos
      link_to place_image_tag(place, opts[:size]), place_photos_path(place)
    else
      "<a #{place_href(place)} class='#{opts[:class]}' #{ ("target=" + opts[:target]) if opts[:target]}>
      #{place_image_tag(place, opts[:size])}
      </a>".html_safe
    end
  end

  def place_href(place, opts={})
    place_path(place)
  end

end
