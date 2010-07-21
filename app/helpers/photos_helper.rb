module PhotosHelper
  
  def linked_scaled_photo(photo, album)
    link_to (image_tag photo.image.url(:scaled_full)), photo_path(album.next_photo(photo))
  end

  def link_to_prev(photo, album)
    link_to "<< previous", photo_path(album.prev_photo(photo))
  end

  def link_to_next(photo, album)
    link_to "next >>", photo_path(album.next_photo(photo))
  end
end
