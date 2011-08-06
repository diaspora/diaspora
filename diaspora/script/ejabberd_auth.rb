

class EjabberdAuthentication

  require 'rubygems'
  require 'logger'
  require ::File.expand_path('../../config/environment',  __FILE__)
  #require File.join(File.dirname(__FILE__), '..', 'config', 'environment')
  
  def initialize

    path = "/path/to/diaspora/log/ejabberd_auth.log"
    file = File.open(path, File::WRONLY | File::APPEND | File::CREAT)
    file.sync = true
    logger = Logger.new(file)
    logger.level = Logger::DEBUG

    logger.info "Starting ejabberd authentication service"

    buffer = String.new
    while STDIN.sysread(2, buffer) && buffer.length == 2

      length = buffer.unpack('n')[0]

      operation, username, domain, password = STDIN.sysread(length).split(':')

      logger.info "Operation: #{operation}"

      response = case operation
      when "auth"
        auth username, password.chomp
      when "isuser"
        isuser username
      else
        0
      end

      logger.info "Response: #{response}"

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
