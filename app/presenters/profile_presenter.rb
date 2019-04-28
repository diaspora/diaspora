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
      avatar: AvatarPresenter.new(@presentable).base_hash(true),
      tags:   tags.pluck(:name)
    )
  end

  def for_hovercard
    {
      avatar: AvatarPresenter.new(@presentable).medium,
      tags:   tags.pluck(:name)
    }
  end

  def as_self_api_json
    base_api_json.merge(added_details_api_json).merge(
      searchable:        searchable,
      show_profile_info: public_details,
      nsfw:              nsfw
    )
  end

  def as_other_api_json(all_details)
    return base_api_json unless all_details

    base_api_json.merge(added_details_api_json)
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

  private

  def base_api_json
    {
      name:        [first_name, last_name].compact.join(" ").presence,
      diaspora_id: diaspora_handle,
      avatar:      AvatarPresenter.new(@presentable).base_hash,
      tags:        tags.pluck(:name)
    }.compact
  end

  def added_details_api_json
    {
      birthday: birthday.try(:iso8601),
      gender:   gender,
      location: location_message.plain_text_for_json,
      bio:      bio_message.plain_text_for_json
    }
  end
end
