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
    base_hash.merge(
      relationship:      relationship,
      block:             is_blocked? ? BlockPresenter.new(current_user_person_block).base_hash : false,
      contact:           (!own_profile? && has_contact?) ? {id: current_user_person_contact.id} : false,
      is_own_profile:    own_profile?,
      show_profile_info: public_details? || own_profile? || person_is_following_current_user
    )
  end

  def as_json(_options={})
    full_hash_with_profile
  end

  protected

  def own_profile?
    current_user.try(:person) == @presentable
  end

  def relationship
    return false unless current_user
    return :blocked if is_blocked?

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

  def full_hash_with_profile
    attrs = full_hash

    if attrs[:show_profile_info]
      attrs.merge!(profile: ProfilePresenter.new(profile).private_hash)
    else
      attrs.merge!(profile: ProfilePresenter.new(profile).public_hash)
    end

    attrs
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
end
