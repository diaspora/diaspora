# frozen_string_literal: true

class PersonPresenter < BasePresenter
  def base_hash
    {
      id:          id,
      guid:        guid,
      name:        name,
      diaspora_id: diaspora_handle
    }
  end

  def full_hash
    base_hash_with_contact.merge(
      relationship:      relationship,
      block:             is_blocked? ? BlockPresenter.new(current_user_person_block).base_hash : false,
      is_own_profile:    own_profile?,
      show_profile_info: public_details? || own_profile? || person_is_following_current_user
    )
  end

  def as_json(_options={})
    full_hash_with_profile
  end

  def hovercard
    base_hash_with_contact.merge(profile: ProfilePresenter.new(profile).for_hovercard)
  end

  def metas_attributes
    {
      keywords:             {name:     "keywords",    content: comma_separated_tags},
      description:          {name:     "description", content: description},
      og_title:             {property: "og:title",    content: title},
      og_description:       {property: "og:title",    content: description},
      og_url:               {property: "og:url",      content: url},
      og_image:             {property: "og:image",    content: image_url},
      og_type:              {property: "og:type",     content: "profile"},
      og_profile_username:  {property: "og:profile:username",   content: name},
      og_profile_firstname: {property: "og:profile:first_name", content: first_name},
      og_profile_lastname:  {property: "og:profile:last_name",  content: last_name}
    }
  end

  def self.people_names(people)
    people.map(&:name).join(", ")
  end

  protected

  def own_profile?
    current_user.try(:person) == @presentable
  end

  def relationship
    return false unless current_user

    contact = current_user_person_contact
    return :not_sharing unless contact

    %i(mutual sharing receiving).find do |status|
      contact.public_send("#{status}?")
    end || :not_sharing
  end

  def person_is_following_current_user
    return false unless current_user
    contact = current_user_person_contact
    contact && contact.sharing?
  end

  def base_hash_with_contact
    base_hash.merge(
      contact: (!own_profile? && has_contact?) ? contact_hash : false
    )
  end

  def full_hash_with_profile
    attrs = full_hash

    if attrs[:show_profile_info]
      attrs.merge!(profile: ProfilePresenter.new(profile).private_hash)
    else
      attrs.merge!(profile: ProfilePresenter.new(profile).public_hash)
    end

    attrs
  end

  def contact_hash
    ContactPresenter.new(current_user_person_contact).full_hash
  end

  private

  def current_user_person_block
    @block ||= (current_user ? current_user.block_for(@presentable) : Block.none)
  end

  def current_user_person_contact
    @contact ||= (current_user ? current_user.contact_for(@presentable) : Contact.none)
  end

  def has_contact?
    current_user_person_contact.present?
  end

  def is_blocked?
    current_user_person_block.present?
  end

  def title
    name
  end

  def comma_separated_tags
    profile.tags.map(&:name).join(", ") if profile.tags
  end

  def url
    url_for(@presentable)
  end

  def description
    public_details? ? bio : ""
  end

  def image_url
    return AppConfig.url_to @presentable.image_url if @presentable.image_url[0] == "/"
    @presentable.image_url
  end
end
