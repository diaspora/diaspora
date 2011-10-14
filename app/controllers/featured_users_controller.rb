require File.join(Rails.root, 'lib', 'stream', 'featured_users')

class FeaturedUsersController < ApplicationController
  def index
    default_stream_action(Stream::FeaturedUsers)
  end
end
