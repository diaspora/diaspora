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
  
  def album_person(album)
    person = album.person
    if album.person_id == current_user.id
      link_to "you", user_path(current_user)
    else
      link_to person.real_name, person_path(person)
    end
  end
end
