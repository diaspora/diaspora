module AlbumsHelper
  def friends_albums_link
    if params[:friends]
      "Friends Albums"
    else
      link_to 'Friends Albums', albums_path({:friends => true})
    end
  end
  
  def your_albums_link
    if params[:friends]
      link_to 'Your Albums', albums_path
    else
      'Your Albums'
    end
  end
end
