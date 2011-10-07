require File.join(Rails.root, 'lib', 'stream', 'featured_users_stream')

class FeaturedUsersController < ApplicationController
  def index
    default_stream_action(FeaturedUsersStream)
  end
end
