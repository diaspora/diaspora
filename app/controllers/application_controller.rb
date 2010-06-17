class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  def receive
    puts response.inspect
    puts "holy boner batman"
  end

end
