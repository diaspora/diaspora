#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(File.dirname(__FILE__), '..', 'config', 'environment')
require File.join(File.dirname(__FILE__), '..','lib', 'diaspora', 'web_socket')

at_exit do
  begin
    File.delete(PID_FILE)
  rescue
    puts 'Cannot remove pidfile: ' + (PID_FILE ? PID_FILE : "NIL")
  end
end

def write_pidfile
  begin
    f = File.open(PID_FILE, "w")
    f.write(Process.pid)
    f.close
  rescue => e
    puts "Can't write to pidfile!"
    puts e.inspect
  end
end

def debug_pp thing
  pp thing if AppConfig[:socket_debug] || ENV['SOCKET_DEBUG']
end

def process_message
  if Diaspora::WebSocket.length > 0
    message = JSON::parse(Diaspora::WebSocket.next)
    if message
      Diaspora::WebSocket.push_to_user(message['uid'], message['data'])
    end
    EM.next_tick{ process_message}
  else
    EM::Timer.new(1){process_message}
  end
end

$cookie_parser = Rack::Builder.new do
  use ActionDispatch::Cookies
  use ActionDispatch::Session::CookieStore, :key => "_diaspora_session"
  use Warden::Manager do |warden|
    warden.default_scope = :user
    warden.failure_app = Proc.new {|env| [0, {}, nil]}
  end
  
  run Proc.new {|env| [0, {}, env['warden'].user]}
end

def get_user_from_request(request)
  user = $cookie_parser.call(request.merge(
    {"HTTP_COOKIE" => request['cookie'], 
    "action_dispatch.secret_token" => Rails.application.config.secret_token}
  ))[2]
  raise ArgumentError, "user not authenticated" unless user
  user
end

begin
  EM.run {
    Diaspora::WebSocket.initialize_channels

    socket_params = { :host => AppConfig[:socket_host],
                      :port => AppConfig[:socket_port],
                      :debug =>AppConfig[:socket_debug] }

    if AppConfig[:socket_secure] && AppConfig[:socket_private_key_location] && AppConfig[:socket_cert_chain_location]
      socket_params[:secure] = true;
      socket_params[:tls_options] = {
                    :private_key_file => AppConfig[:socket_private_key_location],
                    :cert_chain_file  => AppConfig[:socket_cert_chain_location]
      }
    end

    EventMachine::WebSocket.start( socket_params ) do |ws|

      ws.onopen {
        begin
          debug_pp ws.request
          
          user =  get_user_from_request(ws.request)
          user_id = user.id

          debug_pp "In WSS, suscribing user: #{user.name} with id: #{user_id}"
          sid = Diaspora::WebSocket.subscribe(user_id, ws)

          ws.onmessage { |msg| SocketsController.new.incoming(msg) }

          ws.onclose {
            begin
              debug_pp "In WSS, unsuscribing user: #{user.name} with id: #{user_id}"
              Diaspora::WebSocket.unsubscribe(user_id, sid)
            rescue
              debug_pp "Could not unsubscribe socket for #{user_id}"
            end
          }
        rescue ArgumentError => e
          raise e unless e.message.include?("not authenticated")
          debug_pp "Could not open socket for request with cookie: #{ws.request["cookie"]}"
          debug_pp "Looks like the cookie is invalid or the user isn't signed in"
        end
      }
    end
    PID_FILE = (AppConfig[:socket_pidfile] ? AppConfig[:socket_pidfile] : 'tmp/diaspora-ws.pid')
    write_pidfile
    puts "Websocket server started."
    process_message
  }
rescue RuntimeError => e
  raise e unless e.message.include?("no acceptor")
  puts "Are you sure the websocket server isn't already running?"
  puts "Just start thin with bundle exec thin start."
  Process.exit
end
