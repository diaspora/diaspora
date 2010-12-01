module DeviseInvitable::Controllers::Helpers
  protected
  def authenticate_resource!
    ActiveSupport::Deprecation.warn('authenticate_resource! has been renamed to authenticate_inviter!')
    authenticate_inviter!
  end

  def authenticate_inviter!
    send(:"authenticate_#{resource_name}!")
  end
end
ActionController::Base.send :include, DeviseInvitable::Controllers::Helpers
