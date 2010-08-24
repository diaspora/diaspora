module PhotosHelper
  
  def linked_scaled_photo(photo, album)
    link_to (image_tag photo.url(:scaled_full)), photo_path(album.next_photo(photo)), :rel => "prefetch"
  end

  def url_to_prev(photo, album)
    photo_path(album.prev_photo(photo))
  end

  def url_to_next(photo, album)
    photo_path(album.next_photo(photo))
  end
end
