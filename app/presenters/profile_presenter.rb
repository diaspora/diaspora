# frozen_string_literal: true

class ProfilePresenter < BasePresenter
  include PeopleHelper

  def base_hash
    {
      id:         id,
      searchable: searchable
    }
  end

  def public_hash
    base_hash.merge(
      avatar: AvatarPresenter.new(@presentable).base_hash,
      tags:   tags.pluck(:name)
    )
  end

  def for_hovercard
    {
      avatar: AvatarPresenter.new(@presentable).medium,
      tags:   tags.pluck(:name)
    }
  end

  def private_hash
    public_hash.merge(
      bio:      bio_message.plain_text_for_json,
      birthday: formatted_birthday,
      gender:   gender,
      location: location_message.plain_text_for_json
    )
  end

  def formatted_birthday
    birthday_format(birthday) if birthday
  end
end
