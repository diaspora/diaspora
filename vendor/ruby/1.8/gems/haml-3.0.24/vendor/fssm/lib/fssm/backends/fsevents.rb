require File.join(File.dirname(__FILE__), 'rubycocoa/fsevents')

module FSSM::Backends
  class FSEvents
    def initialize
      @handlers = {}
      @fsevents = []
    end

    def add_handler(handler, preload=true)
      @handlers[handler.path.to_s] = handler

      fsevent = Rucola::FSEvents.new(handler.path.to_s, {:latency => 0.5}) do |events|
        events.each do |event|
          handler.refresh(event.path)
        end
      end

      fsevent.create_stream
      handler.refresh(nil, true) if preload
      fsevent.start
      @fsevents << fsevent
    end

    def run
      begin
        OSX.CFRunLoopRun
      rescue Interrupt
        @fsevents.each do |fsev|
          fsev.stop
        end
      end
    end

  end
end
