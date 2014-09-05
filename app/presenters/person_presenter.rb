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
    contact = current_user.contact_for(@presentable)

    is_blocked   = current_user.blocks.where(person_id: id).limit(1).any?
    is_mutual    = contact ? contact.mutual?    : false
    is_sharing   = contact ? contact.sharing?   : false
    is_receiving = contact ? contact.receiving? : false

    if is_blocked      then :blocked
    elsif is_mutual    then :mutual
    elsif is_sharing   then :sharing
    elsif is_receiving then :receiving
    else                    :not_sharing
    end
  end

  def person_is_following_current_user
    @presentable.shares_with(@current_user)
  end
end
