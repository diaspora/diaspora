class FeatureFlagger
  def initialize(current_user)
    @current_user = current_user
  end

  def new_publisher?
    admin? || developer?
  end

  def new_profile?
    admin?
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

end
