
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

      `echo "#{[operation, username, domain, password, response].join(' ')}" >> /home/lasek/Scrivania/foo.txt`

      STDOUT.syswrite([2, response].pack('nn'))
    end

  rescue Exception => exception
    puts "Exception #{exception.to_s}"
  end


  def auth(username, pass_or_session)
      $conn.headers['cookie'] = '_diaspora_session=' + pass_or_session
      r = $conn.post '/users/sign_in.json', {:user => {:username => username, :password => pass_or_session}}, 'Content-Type' => 'application/json'
      puts r.status
      return (r.status == 401) ? 0 : 1
  end

  def isuser(username)
      r = $conn.get '/u/' + username, 'Content-Type' => 'text/html'
      puts r.status
      return (r.status == 404) ? 0 : 1
  end
end

EjabberdAuthentication.new
