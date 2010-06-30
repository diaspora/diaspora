class ApplicationController < ActionController::Base
  protect_from_forgery :except => :receive
  layout 'application'
  
  before_filter :set_friends

  layout :layout_by_resource

  def layout_by_resource
    if devise_controller?
      "session_wall"
    else
      "application"
    end
  end
  
  def set_friends
    @friends = Friend.all
  end
  
end
