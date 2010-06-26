class ApplicationController < ActionController::Base
  protect_from_forgery :except => :receive
  layout 'application'
  before_filter :set_friends
  
  def set_friends
    @friends = Friend.all
  end
  
end
