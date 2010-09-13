#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


require 'em-websocket'
require 'eventmachine'
require "lib/diaspora/websocket"
  EM.next_tick {
    Diaspora::WebSocket.initialize_channels
    
    EventMachine::WebSocket.start(
                  :host => "0.0.0.0", 
                  :port => APP_CONFIG[:socket_port],
                  :debug =>APP_CONFIG[:socket_debug]) do |ws|
      ws.onopen {
        
        sid = Diaspora::WebSocket.subscribe(ws.request['Path'].gsub('/',''), ws)
        
        ws.onmessage { |msg| SocketsController.new.incoming(msg) }

        ws.onclose { Diaspora::WebSocket.unsubscribe(ws.request['Path'].gsub('/',''), sid) }
      }
    end
  }

