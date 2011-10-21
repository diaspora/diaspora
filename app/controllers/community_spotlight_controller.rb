require File.join(Rails.root, 'lib', 'stream', 'community_spotlight')

class CommunitySpotlightController < ApplicationController
  def index
    default_stream_action(Stream::CommunitySpotlight)
  end
end
