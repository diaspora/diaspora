class UserApplicationsPresenter
  def initialize(user)
    @current_user = user
  end

  def user_applications
    @applications ||= @current_user.o_auth_applications.each_with_object([]) do |app, array|
      array << app_as_json(app)
    end
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
    scopes = Api::OpenidConnect::Authorization.find_by_client_id_and_user(
      application.client_id, @current_user).scopes
    scopes.each_with_object([]) {|scope, array| array << scope.name }
  end

  def find_id(application)
    Api::OpenidConnect::Authorization.find_by_client_id_and_user(
      application.client_id, @current_user).id
  end
end
