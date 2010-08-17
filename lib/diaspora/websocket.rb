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
      Rails.logger.debug "Subscribing socket to #{User.first(:id => uid).email}"
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
      SocketsController.new.outgoing(id, self, :group => opts[:group_id])
    end
    
    def unsocket_from_uid id
      SocketsController.new.outgoing(id, Retraction.for(self))
    end

  end
end
