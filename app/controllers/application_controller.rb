class ApplicationController < ActionController::Base
  protect_from_forgery :except => :receive
  layout 'application'

  def receive
    puts params.inspect
    puts "holy boner batman"
    render :nothing => true
  end

end
