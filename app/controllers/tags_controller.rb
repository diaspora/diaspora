# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class TagsController < ApplicationController
  before_action :ensure_page, :only => :show

  helper_method :tag_followed?

  layout proc { request.format == :mobile ? "application" : "with_header" }, only: :show

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
        format.json { head :unprocessable_entity }
        format.html { redirect_to tag_path("partytimeexcellent") }
      end
    end
  end

  def show
    redirect_to(:action => :show, :name => downcased_tag_name) && return if tag_has_capitals?

    if user_signed_in?
      gon.preloads[:tagFollowings] = tags
    end
    stream = Stream::Tag.new(current_user, params[:name], max_time: max_time, page: params[:page])
    @stream = TagStreamPresenter.new(stream)
    respond_with do |format|
      format.json do
        posts = stream.stream_posts.map do |p|
          LastThreeCommentsDecorator.new(PostPresenter.new(p, current_user))
        end
        render json: posts
      end
    end
  end

  private

  def tag_followed?
    TagFollowing.user_is_following?(current_user, params[:name])
  end

  def tag_has_capitals?
    mb_tag = params[:name].mb_chars
    mb_tag.downcase != mb_tag
  end

  def downcased_tag_name
    params[:name].mb_chars.downcase.to_s
  end

  def prep_tags_for_javascript
    @tags = @tags.map {|tag|
      { :name  => ("#" + tag.name) }
    }

    @tags << { :name  => ('#' + params[:q]) }
    @tags.uniq!
  end
end
