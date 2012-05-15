class FeatureFlagger
  def initialize(current_user, person_being_viewed=nil)
    @current_user = current_user
    @person = person_being_viewed
  end

  def new_publisher?
    beta? || admin? || developer?
  end

  def new_profile?
    person_is_beta?
  end

  def new_stream?
    admin? && beta?
  end

  def new_hotness?
    ENV["NEW_HOTNESS"]
  end

  def following_enabled?
    person_is_beta? && @current_user.contacts.receiving.count == 0
  end

  protected

  def developer?
    !(Rails.env.production? || Rails.env.staging?) #includes test, cucumber, or developer
  end

  def admin?
    @current_user.try(:admin?)
  end

  def beta?
    Role.is_beta?(@current_user.person)
  end

  def person_is_beta?
    return unless @person.present?
    Role.is_beta?(@person) || Role.is_admin?(@person)
  end
end
