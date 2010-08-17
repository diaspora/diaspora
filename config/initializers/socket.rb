require 'em-websocket'
require 'eventmachine'
require "lib/diaspora/websocket"
  EM.next_tick {
    Diaspora::WebSocket.initialize_channels
    
    EventMachine::WebSocket.start(
                  :host => "0.0.0.0", 
                  :port => APP_CONFIG[:socket_port],
                  :debug =>APP_CONFIG[:debug]) do |ws|
      ws.onopen {
        
        sid = Diaspora::WebSocket.subscribe(ws.request['Path'].gsub('/',''), ws)
        
        ws.onmessage { |msg| SocketsController.new.incoming(msg) }

        ws.onclose { Diaspora::WebSocket.unsubscribe(ws.request['Path'].gsub('/',''), sid) }
      }
    end
  }

