#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


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
