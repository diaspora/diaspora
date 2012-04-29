class FeatureFlagger
  def initialize(current_user, person=nil)
    @current_user = current_user
    @person = person
  end

  def new_publisher?
    admin? || developer?
  end

  def new_profile?
    person_is_beta?
  end

  def new_hotness?
    ENV["NEW_HOTNESS"]
  end

  protected

  def developer?
    !(Rails.env.production? || Rails.env.staging?) #includes test, cucumber, or developer
  end

  def admin?
    @current_user.try(:admin?)
  end

  def person_is_beta?
    return unless @person.present?
    Role.is_beta?(@person) || Role.is_admin?(@person)
  end

end
