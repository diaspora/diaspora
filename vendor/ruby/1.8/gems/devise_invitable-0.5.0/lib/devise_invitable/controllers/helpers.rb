module DeviseInvitable::Controllers::Helpers
  protected
  def authenticate_inviter!
    send(:"authenticate_#{resource_name}!", true)
  end
end
ActionController::Base.send :include, DeviseInvitable::Controllers::Helpers
