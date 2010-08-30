class GroupsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def index
    @posts = current_user.visible_posts(:by_members_of => :all).paginate :page => params[:page], :order => 'created_at DESC'
    @group = :all
  end

  def create
    @group = current_user.group params[:group]
    respond_with @group
  end
  
  def new
    @group = Group.new
  end
  
  def destroy
    @group = Group.find_by_id params[:id]
    @group.destroy
    respond_with :location => groups_url
  end
  
  def show
    @group   = Group.find_by_id params[:id]
    @friends = @group.people
    @posts   = current_user.visible_posts( :by_members_of => @group ).paginate :order => 'created_at DESC'

    respond_with @group
  end

  def edit
    @groups = current_user.groups
    @group  = Group.find_by_id params[:id]
  end

  def update
    @group = Group.find_by_id(params[:id])
    @group.update_attributes(params[:group])
    respond_with @group
  end

  def move_friends
    params[:moves].each{ |move|
      move = move[1]
      unless current_user.move_friend(move)
        flash[:error] = "Group editing failed for friend #{Person.find_by_id( move[:friend_id] ).real_name}."
        redirect_to Group.first, :action => "edit"
        return
      end
    }

    flash[:notice] = "Groups edited successfully."
    redirect_to Group.first, :action => "edit"
  end

  def move_friend
    unless current_user.move_friend( :friend_id => params[:friend_id], :from => params[:from], :to => params[:to][:to]) 
      flash[:error] = "didn't work #{params.inspect}"
    end
    if group = Group.first(:id => params[:to][:to])
      redirect_to group 
    else
      redirect_to Person.first(:id => params[:friend_id])
    end
  end
end
