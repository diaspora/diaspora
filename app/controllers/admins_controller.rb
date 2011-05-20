class AdminsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_unless_admin

  def user_search
    params[:user] ||= {}
    params[:user].delete_if {|key, value| value.blank? }
    @users = params[:user].empty? ? [] : User.where(params[:user])
  end

  def add_invites
    user = User.find(params[:user_id])

    if user.increment(:invites, 10).save
      flash[:notice] = "Great Job!"
    else
      flash[:alert] = "there was a problem adding invites"
    end

    redirect_to user_search_path(:user => { :id => user.id })
  end

  def admin_inviter
    opts = {:service => 'email', :identifier => params[:identifier]}
    existing_user = Invitation.find_existing_user('email', params[:identifier])
    opts.merge!(:existing_user => existing_user) if existing_user
    Invitation.create_invitee(opts)
    flash[:notice] = "invitation sent to #{params[:identifier]}"
    redirect_to user_search_path
  end
end
