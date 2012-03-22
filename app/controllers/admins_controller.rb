require File.join(Rails.root, 'lib','statistics')

class AdminsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_unless_admin

  def user_search
    params[:user] ||= {}
    params[:user].delete_if {|key, value| value.blank? }
    @users = params[:user].empty? ? [] : User.where(params[:user])
  end

  def admin_inviter 
    inviter = InvitationCode.default_inviter_or(current_user)
    email = params[:identifier]
    user = User.find_by_email(email)
    
    unless user
      EmailInviter.new(email, inviter).send!
      flash[:notice] = "invitation sent to #{email}"
    else
      flash[:notice]= "error sending invite to #{email}"
    end
    redirect_to user_search_path, :notice => flash[:notice]
  end

  def add_invites
    InvitationCode.find_by_token(params[:invite_code_id]).add_invites!
    redirect_to user_search_path
  end

  def weekly_user_stats
    @created_users = User.where("username IS NOT NULL")
    @created_users_by_week =  Hash.new{ |h,k| h[k] = [] }
    @created_users.each do |u| 
      unless u.nil?
          @created_users_by_week[u.created_at.beginning_of_week.strftime("%Y-%m-%d")].push("#{u.username}")
        end
      end

    unless(params[:week]).nil?
      # @segment = "#{@created_users_by_week[(params[:week])]}" 
      @counter = "#{@created_users_by_week[(params[:week])].count}"
    else
      @segment = "date not found"
    end
  end

  def stats
    @popular_tags = ActsAsTaggableOn::Tagging.joins(:tag).limit(50).count(:group => :tag, :order => 'count(taggings.id) DESC')

    case params[:range]
    when "week"
      range = 1.week
      @segment = "week"
    when "2weeks"
      range = 2.weeks
      @segment = "2 week"
    when "month"
      range = 1.month
      @segment = "month"
    else
      range = 1.day
      @segment = "daily"
    end

    [Post, Comment, AspectMembership, User].each do |model|
      create_hash(model, :range => range)
    end

    @posts_per_day = Post.count(:group => "DATE(created_at)", :conditions => ["created_at >= ?", Date.today - 21.days], :order => "DATE(created_at) ASC")
    @most_posts_within = @posts_per_day.values.max.to_f

    @user_count = User.count

    #@posts[:new_public] = Post.where(:type => ['StatusMessage','ActivityStreams::Photo'],
    #                                 :public => true).order('created_at DESC').limit(15).all

  end

  def correlations
    @correlations_hash = Statistics.new.generate_correlations
  end

  private
  def percent_change(today, yesterday)
    sprintf( "%0.02f", ((today-yesterday) / yesterday.to_f)*100).to_f
  end

  def create_hash(model, opts={})
    opts[:range] ||= 1.day
    plural = model.to_s.underscore.pluralize
    eval(<<DATA
      @#{plural} = {
        :day_before => #{model}.where(:created_at => ((Time.now.midnight - #{opts[:range]*2})..Time.now.midnight - #{opts[:range]})).count,
        :yesterday => #{model}.where(:created_at => ((Time.now.midnight - #{opts[:range]})..Time.now.midnight)).count
      }
      @#{plural}[:change] = percent_change(@#{plural}[:yesterday], @#{plural}[:day_before])
DATA
    )
  end
end
