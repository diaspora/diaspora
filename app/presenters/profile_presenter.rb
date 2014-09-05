class ProfilePresenter < BasePresenter
  def base_hash
    {  id: id,
       tags: tag_string,
       bio: bio,
       location: location,
       gender: gender,
       birthday: formatted_birthday,
       searchable: searchable
    }
  end

  def full_hash
    base_hash.merge({
      avatar: AvatarPresenter.new(@presentable).base_hash,
    })
  end
end
