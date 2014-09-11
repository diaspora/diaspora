class PersonPresenter < BasePresenter
  def base_hash
    { id: id,
      guid: guid,
      name: name,
      diaspora_id: diaspora_handle
    }
  end

  def full_hash
    base_hash.merge({
      relationship: relationship,
      block: is_blocked? ? BlockPresenter.new(current_user_person_block).base_hash : false,
      contact: (!own_profile? && has_contact?) ? { id: current_user_person_contact.id } : false,
      is_own_profile: own_profile?
    })
  end

  def full_hash_with_avatar
    full_hash.merge({avatar: AvatarPresenter.new(profile).base_hash})
  end

  def full_hash_with_profile
    full_hash.merge({profile: ProfilePresenter.new(profile).full_hash})
  end

  def as_json(options={})
    attrs = full_hash_with_avatar

    if own_profile? || person_is_following_current_user
      attrs.merge!({
                      :location => @presentable.location,
                      :birthday => @presentable.formatted_birthday,
                      :bio => @presentable.bio
                  })
    end

    attrs
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

    [:mutual, :sharing, :receiving].find do |status|
      contact.public_send("#{status}?")
    end || :not_sharing
  end

  def person_is_following_current_user
    @presentable.shares_with(current_user)
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
