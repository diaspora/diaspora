class ApplicationController < ActionController::Base
  require 'lib/diaspora/ostatus_generator'
  
  protect_from_forgery :except => :receive
  layout 'application'
  
  before_filter :set_friends_and_authors, :count_requests

  layout :layout_by_resource

  def layout_by_resource
    if devise_controller?
      "session_wall"
    else
      "application"
    end
  end
  
  def set_friends_and_authors
    @friends = Person.friends.all if current_user
    @subscribed_persons = Author.all if current_user
  end

  def count_requests
    @request_count = Request.for_user(current_user).size if current_user
  end
  
end
