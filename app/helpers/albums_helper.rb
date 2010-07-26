module AlbumsHelper
  def friends_albums_link
    if params[:friends]
      "friends albums"
    else
      link_to 'friends albums', albums_path({:friends => true})
    end
  end
  
  def your_albums_link
    if params[:friends]
      link_to 'your albums', albums_path
    else
      'your albums'
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