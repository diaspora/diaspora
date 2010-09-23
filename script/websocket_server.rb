#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require File.dirname(__FILE__) + '/../config/environment'
require File.dirname(__FILE__) + '/../lib/diaspora/websocket'

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

        sid = Diaspora::WebSocket.subscribe(ws.request['Path'].gsub('/',''), ws)

        ws.onmessage { |msg| SocketsController.new.incoming(msg) }

        ws.onclose { Diaspora::WebSocket.unsubscribe(ws.request['Path'].gsub('/',''), sid) }
      }
    end

    puts "Websocket server started."
    process_message
  }
rescue RuntimeError => e
  raise e unless e.message.include?("no acceptor")
  puts "Are you sure the websocket server isn't already running?"
  puts "Just start thin with bundle exec thin start."
  Process.exit
end
