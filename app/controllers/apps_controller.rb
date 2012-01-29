class AppsController < ApplicationController
  def show
    @app = 'cubbies'
    @posts = ActivityStreams::Photo.where(:public => true).for_a_stream(max_time, 'created_at')
    @commenting_disabled = true
    @people = []
    @people_count = 0
  end
end
