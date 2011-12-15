class ApisController < ApplicationController
  authenticate_with_oauth
  before_filter :set_user_from_oauth
  respond_to :json

  def me
#    debugger
    @person = @user.person
    render :json => {
                      :birthday => @person.profile.birthday,
                      :name => @person.name,
                      :uid => @user.username
                    }
  end

  private
  def set_user_from_oauth
    @user = request.env['oauth2'].resource_owner
  end
end
