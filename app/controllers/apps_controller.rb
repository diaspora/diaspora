class AppsController < ApplicationController
  def show
    @app = 'cubbies'
    @posts = ActivityStreams::Photo
    max_time = params[:max_time] ? Time.at(params[:max_time].to_i) : Time.now
    @posts = @posts.where(ActivityStreams::Photo.arel_table[:created_at].lt(max_time)
                         ).where(:public => true
                         ).order('posts.created_at DESC'
                         ).includes(:author => :profile).limit(30)
    @commenting_disabled = true
    @people = []
    @people_count = 0
  end
end
