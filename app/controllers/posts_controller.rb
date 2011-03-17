#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PostsController < ApplicationController
  skip_before_filter :count_requests
  skip_before_filter :set_invites
  skip_before_filter :which_action_and_user
  skip_before_filter :set_grammatical_gender

  def index
    if current_user
      @posts = StatusMessage.joins(:aspects).where(:pending => false
               ).where(Aspect.arel_table[:user_id].eq(current_user.id).or(StatusMessage.arel_table[:public].eq(true))
               ).select('DISTINCT `posts`.*')
    else
      @posts = StatusMessage.where(:public => true, :pending => false)
    end

    params[:tag] ||= 'partytimeexcellent'

    @posts = @posts.tagged_with(params[:tag])
    @posts = @posts.includes(:comments, :photos).paginate(:page => params[:page], :per_page => 15, :order => 'created_at DESC')

    profiles = Profile.tagged_with(params[:tag]).where(:searchable => true).select('profiles.id, profiles.person_id')
    @people = Person.where(:id => profiles.map{|p| p.person_id}).limit(15)
    @people_count = Person.where(:id => profiles.map{|p| p.person_id}).count

    @fakes = PostsFake.new(@posts)
    @commenting_disabled = true
    @pod_url = AppConfig[:pod_uri].host
  end

  def show
    @post = Post.where(:id => params[:id], :public => true).includes(:author, :comments => :author).first

    if @post
      @landing_page = true
      @person = @post.author
      if @person.owner_id
        I18n.locale = @person.owner.language
        render "posts/#{@post.class.to_s.underscore}", :layout => true
      else
        flash[:error] = I18n.t('posts.doesnt_exist')
        redirect_to root_url
      end
    else
      flash[:error] = I18n.t('posts.doesnt_exist')
      redirect_to root_url
    end
  end
end
