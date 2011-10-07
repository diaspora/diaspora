#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require File.join(Rails.root, 'app', 'models', 'acts_as_taggable_on_tag')

class TagsController < ApplicationController
  skip_before_filter :which_action_and_user
  skip_before_filter :set_grammatical_gender
  before_filter :ensure_page, :only => :show

  helper_method :tag_followed?

  respond_to :html, :only => [:show]
  respond_to :json, :only => [:index]

  def index
    if params[:q] && params[:q].length > 1 && request.format.json?
      params[:q].gsub!("#", "")
      params[:limit] = !params[:limit].blank? ? params[:limit].to_i : 10
      @tags = ActsAsTaggableOn::Tag.named_like(params[:q]).limit(params[:limit] - 1)
      @tags.map! do |obj|
        { :name => ("#"+obj.name),
          :value => ("#"+obj.name),
          :url => tag_path(obj.name)
        }
      end

      @tags << {
        :name => ('#' + params[:q]),
        :value => ("#" + params[:q]),
        :url => tag_path(params[:q].downcase)
      }
      @tags.uniq!

      respond_to do |format|
        format.json{
          render(:json => @tags.to_json, :status => 200)
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
    @tag = ActsAsTaggableOn::Tag.find_by_name(params[:name])
    @tag_follow_count = @tag.try(:followed_count).to_i

    if current_user
      @posts = StatusMessage.owned_or_visible_by_user(current_user)
    else
      @posts = StatusMessage.all_public
    end

    @posts = @posts.tagged_with(params[:name]).for_a_stream(max_time, 'created_at')

    @commenting_disabled = true
    params[:prefill] = "##{params[:name]} "

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
