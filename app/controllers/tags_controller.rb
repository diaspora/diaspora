#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require File.join(Rails.root, 'app', 'models', 'acts_as_taggable_on', 'tag')
require File.join(Rails.root, 'lib', 'stream', 'tag')

class TagsController < ApplicationController
  skip_before_filter :which_action_and_user
  skip_before_filter :set_grammatical_gender
  before_filter :ensure_page, :only => :show

  helper_method :tag_followed?

  respond_to :html, :only => [:show]
  respond_to :json, :only => [:index, :show]

  def index
    if params[:q] && params[:q].length > 1
      params[:q].gsub!("#", "")
      params[:limit] = !params[:limit].blank? ? params[:limit].to_i : 10
      @tags = ActsAsTaggableOn::Tag.autocomplete(params[:q]).limit(params[:limit] - 1)
      prep_tags_for_javascript

      respond_to do |format|
        format.json{ render(:json => @tags.to_json, :status => 200) }
      end
    else
      respond_to do |format|
        format.json{ render :nothing => true, :status => 422 }
        format.html{ redirect_to tag_path('partytimeexcellent') }
      end
    end
  end

  def show
    @stream = Stream::Tag.new(current_user, params[:name], :max_time => max_time, :page => params[:page])

    respond_with do |format|
      format.json{ render_for_api :backbone, :json => @stream.stream_posts, :root => :posts }
    end
  end

 def tag_followed?
   if @tag_followed.nil?
     @tag_followed = TagFollowing.joins(:tag).where(:tags => {:name => params[:name]}, :user_id => current_user.id).exists?
   end
   @tag_followed
 end

  def prep_tags_for_javascript
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
  end
end
