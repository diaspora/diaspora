module Cucumber
  class Broadcaster #:nodoc:
    def initialize(receivers = [])
      @receivers = receivers
    end

    def method_missing(method_name, *args)
      @receivers.map do |receiver|
        receiver.__send__(method_name, *args)
      end
    end
  end
end
