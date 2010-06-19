class ApplicationController < ActionController::Base
  protect_from_forgery :except => :receive
  layout 'application'

  
end
