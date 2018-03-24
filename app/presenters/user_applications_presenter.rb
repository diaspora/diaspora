# frozen_string_literal: true

class UserApplicationsPresenter
  def initialize(user)
    @user = user
  end

  def user_applications
    @applications ||= @user.o_auth_applications.map do |app|
      authorization = Api::OpenidConnect::Authorization.find_by_client_id_and_user(app.client_id, @user)
      UserApplicationPresenter.new app, authorization.scopes, authorization.id
    end
  end

  def applications_count
    user_applications.size
  end

  def applications?
    applications_count > 0
  end
end
