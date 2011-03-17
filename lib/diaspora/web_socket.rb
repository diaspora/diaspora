#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module WebSocket

    REDIS_CONNECTION_SET = 'ws-uids'

    def self.redis
      @redis ||= Resque.redis
    end
    def self.length
      redis.llen :websocket
    end
    def self.queue_to_user(uid, data)
      redis.lpush(:websocket, {:uid => uid, :data => data}.to_json)
    end

    def self.initialize_channels
      @channels = {}
    end

    def self.next
      redis.rpop(:websocket)
    end

    def self.push_to_user(uid, data)
      Rails.logger.debug "event=socket-push uid=#{uid}"
      @channels[uid][0].push(data) if @channels[uid]
    end

    def self.subscribe(uid, ws)
      Rails.logger.info "event=socket-subscribe uid=#{uid} channels=#{self.length}"
      self.ensure_channel(uid)
      @channels[uid][0].subscribe{ |msg| ws.send msg }
      @channels[uid][1] += 1

      redis.sadd(REDIS_CONNECTION_SET, uid)
    end

    def self.ensure_channel(uid)
      @channels[uid] ||= [EM::Channel.new, 0 ]
    end

    def self.unsubscribe(uid,sid)
      Rails.logger.info "event=socket-unsubscribe sid=#{sid} uid=#{uid} channels=#{self.length}"
      @channels[uid][0].unsubscribe(sid) if @channels[uid]
      @channels[uid][1] -= 1
      if @channels[uid][1] <= 0
        @channels.delete(uid)
        redis.srem(REDIS_CONNECTION_SET, uid)
      end
    end

    def self.is_connected?(uid)
      redis.sismember(REDIS_CONNECTION_SET, uid)
    end
  end

  module Socketable
    def socket_to_user(user_or_id, opts={})
      SocketsController.new.outgoing(user_or_id, self, opts)
    end

    def unsocket_from_user(user_or_id, opts={})
      SocketsController.new.outgoing(user_or_id, Retraction.for(self), opts)
    end
  end
end
