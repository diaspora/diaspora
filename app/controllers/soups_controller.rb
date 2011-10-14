require File.join(Rails.root, 'lib', 'stream', 'soup_stream')

class SoupsController < ApplicationController
  before_filter :redirect_unless_admin

  def index 
    default_stream_action(SoupStream)
  end
end
