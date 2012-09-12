class FeatureFlagger
  def initialize(current_user, person_being_viewed=nil)
    @current_user = current_user
    @person = person_being_viewed
  end

  protected

  def developer?
    !(Rails.env.production? || Rails.env.staging?) #includes test, cucumber, or developer
  end

  def admin?
    @current_user.try(:admin?)
  end

end
