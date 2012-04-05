class FeatureFlagger
  def initialize(current_user)
    @current_user = current_user
  end

  def new_publisher?
    @current_user.admin? || !(Rails.env.production? || Rails.env.staging?)
  end
end
