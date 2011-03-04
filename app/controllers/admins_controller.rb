class AdminsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_unless_admin

  def user_search
    user = params[:user] || {}
    user = user.delete_if {|key, value| value.blank? }
    params[:user] = user

    if user.keys.count == 0
      @users = []
    else
      @users = User.where(params[:user]).all || []
    end

    render 'user_search'
  end

  def admin_inviter
    opts = {:service => 'email', :identifier => params[:identifier]}
    existing_user = Invitation.find_existing_user('email', params[:identifier])
    opts.merge!(:existing_user => existing_user) if existing_user
    Invitation.create_invitee(opts)
    flash[:notice] = "invitation sent to #{params[:identifier]}"
    redirect_to '/admins/user_search'
  end
end
