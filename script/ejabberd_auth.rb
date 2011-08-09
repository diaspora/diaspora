
class EjabberdAuthentication

  require 'rubygems'
  require ::File.expand_path('../../config/environment',  __FILE__)
  #require File.join(File.dirname(__FILE__), '..', 'config', 'environment')
  
  def initialize

    buffer = String.new
    while STDIN.sysread(2, buffer) && buffer.length == 2

      length = buffer.unpack('n')[0]

      operation, username, domain, password = STDIN.sysread(length).split(':')

      response = case operation
      when "auth"
        auth username, password.chomp
      when "isuser"
        isuser username
      else
        0
      end

      STDOUT.syswrite([2, response].pack('nn'))
    end

  rescue Exception => exception
    pp "Exception #{exception.to_s}"
  end


  def auth(username, password)
    return ::User.find_by_username(username).valid_password?(password) ? 1 : 0
  end

  def isuser(username)
    return ::User.find_by_username(username) ? 1 : 0
  end

  EjabberdAuthentication.new

end
