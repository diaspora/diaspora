class ProfilePresenter < BasePresenter
  include PeopleHelper

  def base_hash
    {  id: id,
       tags: tags.pluck(:name),
       bio: bio_message.plain_text_for_json,
       location: location_message.plain_text_for_json,
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

  def formatted_birthday
    birthday_format(birthday) if birthday
  end
end
