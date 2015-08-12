class UserApplicationsPresenter
  def initialize(user)
    @user = user
  end

  def user_applications
    @applications ||= @user.o_auth_applications.map {|app| app_as_json(app) }
  end

  def applications_count
    user_applications.size
  end

  def applications?
    applications_count > 0
  end

  private

  def app_as_json(application)
    {
      id:             find_id(application),
      name:           application.client_name,
      image:          application.image_uri,
      authorizations: find_scopes(application)
    }
  end

  def find_scopes(application)
    find_auth(application).scopes
  end

  def find_id(application)
    find_auth(application).id
  end

  def find_auth(application)
    Api::OpenidConnect::Authorization.find_by_client_id_and_user(application.client_id, @user)
  end
end
