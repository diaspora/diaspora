module Diaspora
  class Websocket

    def initialize(*args)
    end

    def self.to(*args)
      w = Websocket.new(*args)
      w
    end

    def send(object)
    end

    def retract(object)
    end

    alias :socket :send
    alias :unsocket :retract
  end
end
