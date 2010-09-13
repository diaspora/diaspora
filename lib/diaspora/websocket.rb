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



module Diaspora
  module WebSocket
    def self.initialize_channels
      @channels = {} 
    end
    
    def self.push_to_user(uid, data)
      Rails.logger.debug "Websocketing to #{uid}"
      @channels[uid.to_s][0].push(data) if @channels[uid.to_s]
    end
    
    def self.subscribe(uid, ws)
      Rails.logger.debug "Subscribing socket to #{uid}"
      self.ensure_channel(uid)
      @channels[uid][0].subscribe{ |msg| ws.send msg }
      @channels[uid][1] += 1
    end

    def self.ensure_channel(uid)
      @channels[uid] ||= [EM::Channel.new, 0 ]
    end

    def self.unsubscribe(uid,sid)
      Rails.logger.debug "Unsubscribing socket #{sid} from #{uid}"
      @channels[uid][0].unsubscribe(sid) if @channels[uid]
      @channels[uid][1] -= 1
      if @channels[uid][1] <= 0
        @channels.delete(uid)
      end
    end
  end

  module Socketable
    def socket_to_uid(id, opts={})
      SocketsController.new.outgoing(id, self, opts)
    end
    
    def unsocket_from_uid(id, opts={})
      SocketsController.new.outgoing(id, Retraction.for(self), opts)
    end

  end
end
