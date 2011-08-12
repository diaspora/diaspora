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

  def stats
    @popular_tags = ActsAsTaggableOn::Tagging.joins(:tag).limit(15).count(:group => :tag, :order => 'count(taggings.id) DESC')

    [Post, Comment, AspectMembership, User].each do |model|
      create_hash(model)
    end

    @posts[:new_public] = Post.where(:type => ['StatusMessage','ActivityStreams::Photo'],
                                     :public => true).order('created_at DESC').limit(15).all
  end

  private
  def percent_change(today, yesterday)
    sprintf( "%0.02f", ((today-yesterday) / yesterday.to_f)*100).to_f
  end

  def create_hash(model)
    plural = model.to_s.underscore.pluralize
    eval(<<DATA
      @#{plural} = {
        :day_before => #{model}.where(:created_at => ((Time.now.midnight - 2.days)..Time.now.midnight - 1.day)).count,
        :yesterday => #{model}.where(:created_at => ((Time.now.midnight - 1.day)..Time.now.midnight)).count,
        :today => #{model}.where(:created_at => ((Time.now.midnight)..Time.now)).count
      }
      @#{plural}[:change] = percent_change(@#{plural}[:yesterday], @#{plural}[:day_before])
DATA
    )
  end
end
