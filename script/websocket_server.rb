#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.dirname(__FILE__) + '/../config/environment'
require File.dirname(__FILE__) + '/../lib/diaspora/websocket'

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
  pp thing if APP_CONFIG[:socket_debug] || ENV['SOCKET_DEBUG']
end

CHANNEL = Magent::GenericChannel.new('websocket')
def process_message
  if CHANNEL.queue_count > 0
    message = CHANNEL.dequeue
    if message
      Diaspora::WebSocket.push_to_user(message['uid'], message['data'])
    end
    EM.next_tick{ process_message}
  else
    EM::Timer.new(1){process_message}
  end
end

begin
  EM.run {


    Diaspora::WebSocket.initialize_channels

    EventMachine::WebSocket.start(
                  :host => APP_CONFIG[:socket_host],
                  :port => APP_CONFIG[:socket_port],
                  :debug =>APP_CONFIG[:socket_debug]) do |ws|
      ws.onopen {
        debug_pp ws.request

        cookies = ws.request["Cookie"].split(';')
        session_key = "_diaspora_session="
        enc_diaspora_cookie = cookies.detect{|c| c.include?(session_key)}.gsub(session_key,'')
        cookie = Marshal.load(enc_diaspora_cookie.unpack("m*").first)

        debug_pp cookie

        user_id = cookie["warden.user.user.key"].last
        
        debug_pp "In WSS, suscribing user: #{User.find(user_id).real_name} with id: #{user_id}"

        sid = Diaspora::WebSocket.subscribe(user_id, ws)

        ws.onmessage { |msg| SocketsController.new.incoming(msg) }

        ws.onclose {
          debug_pp "In WSS, unsuscribing user: #{User.find(user_id).real_name} with id: #{user_id}"
          Diaspora::WebSocket.unsubscribe(user_id, sid) }
      }
    end
    PID_FILE = APP_CONFIG[:socket_pidfile]
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
