require File.join(Rails.root, 'lib', 'stream', 'soup')

class SoupsController < ApplicationController
  #before_filter :redirect_unless_admin

  def index
    default_stream_action(Stream::Soup)
  end
end
