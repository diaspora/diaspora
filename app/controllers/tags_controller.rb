#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class TagsController < ApplicationController
  skip_before_filter :which_action_and_user
  skip_before_filter :set_grammatical_gender
  before_filter :ensure_page, :only => :show

  helper_method :tag_followed?

  respond_to :html, :only => [:show]
  respond_to :json, :only => [:index]

  def index
    if params[:q] && params[:q].length > 1
      params[:q].gsub!("#", "")
      params[:limit] = !params[:limit].blank? ? params[:limit].to_i : 10
      @tags = ActsAsTaggableOn::Tag.named_like(params[:q]).limit(params[:limit] - 1)
      @array = []
      @tags.each do |obj|
        @array << { :name => ("#"+obj.name),
          :value => ("#"+obj.name)}
      end

      @array << { :name => ('#' + params[:q]), :value => ("#" + params[:q])}
      @array.uniq!

      respond_to do |format|
        format.json{
          render(:json => @array.to_json, :status => 200)
        }
      end
    else
      respond_to do |format|
        format.json{ render :nothing => true, :status => 422 }
        format.html{ redirect_to tag_path('partytimeexcellent') }
      end
    end
  end

  def show
    params[:name].downcase!
    @aspect = :tag
    if current_user
      @posts = StatusMessage.
        joins("LEFT OUTER JOIN post_visibilities ON post_visibilities.post_id = posts.id").
        joins("LEFT OUTER JOIN contacts ON contacts.id = post_visibilities.contact_id").
        where(Contact.arel_table[:user_id].eq(current_user.id).or(
          StatusMessage.arel_table[:public].eq(true).or(
            StatusMessage.arel_table[:author_id].eq(current_user.person.id)
          )
        )).select('DISTINCT posts.*')
    else
      @posts = StatusMessage.where(:public => true, :pending => false)
    end

    @posts = @posts.tagged_with(params[:name])

    max_time = params[:max_time] ? Time.at(params[:max_time].to_i) : Time.now
    @posts = @posts.where(StatusMessage.arel_table[:created_at].lt(max_time))
    @posts = @posts.includes({:author => :profile}, :comments, :photos).order('posts.created_at DESC').limit(15)

    @commenting_disabled = true

    if params[:only_posts]
      render :partial => 'shared/stream', :locals => {:posts => @posts}
    else
      profiles = Profile.tagged_with(params[:name]).where(:searchable => true).select('profiles.id, profiles.person_id')
      @people = Person.where(:id => profiles.map{|p| p.person_id}).paginate(:page => params[:page], :per_page => 15)
      @people_count = Person.where(:id => profiles.map{|p| p.person_id}).count
    end
  end

 def tag_followed?
   if @tag_followed.nil?
     @tag_followed = TagFollowing.joins(:tag).where(:tags => {:name => params[:name]}, :user_id => current_user.id).exists? #,
   end
   @tag_followed
 end
end
