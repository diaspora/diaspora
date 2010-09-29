#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

module AlbumsHelper
  def friends_albums_link
    if params[:friends]
      I18n.t('albums.helper.friends_albums')
    else
      link_to I18n.t('albums.helper.friends_albums'), albums_path({:friends => true})
    end
  end

  def your_albums_link
    if params[:friends]
      link_to I18n.t('albums.helper.your_albums'), albums_path
    else
      I18n.t('albums.helper.your_albums')
    end
  end
end
