
require 'rubygems'
require 'faraday'

$conn = Faraday.new(:url => 'http://localhost:3000') do |builder|
  builder.request  :url_encoded
  builder.request  :json
  builder.response :logger
  builder.adapter  :net_http
end


class EjabberdAuthentication

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
    r = $conn.post '/users/sign_in.json', {:user => {:username => username, :password => password}}, 'Content-Type' => 'application/json'
    r.status == 201 ?  1 : 0 
  end

  def isuser(username)
    # ::User.find_by_username(username) ? 1 : 0
    1	
  end
end

EjabberdAuthentication.new
