OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'

module Rucola
  class FSEvents
    class FSEvent
      attr_reader :fsevents_object
      attr_reader :id
      attr_reader :path

      def initialize(fsevents_object, id, path)
        @fsevents_object, @id, @path = fsevents_object, id, path
      end

      # Returns an array of the files/dirs in the path that the event occurred in.
      # The files are sorted by the modification time, the first entry is the last modified file.
      def files
        Dir.glob("#{File.expand_path(path)}/*").sort_by {|f| File.mtime(f) }.reverse
      end

      # Returns the last modified file in the path that the event occurred in.
      def last_modified_file
        files.first
      end
    end

    class StreamError < StandardError;
    end

    attr_reader :paths
    attr_reader :stream

    attr_accessor :allocator
    attr_accessor :context
    attr_accessor :since
    attr_accessor :latency
    attr_accessor :flags

    # Initializes a new FSEvents `watchdog` object and starts watching the directories you specify for events. The
    # block is used as a handler for events, which are passed as the block's argument. This method is the easiest
    # way to start watching some directories if you don't care about the details of setting up the event stream.
    #
    #   Rucola::FSEvents.start_watching('/tmp') do |events|
    #     events.each { |event| log.debug("#{event.files.inspect} were changed.") }
    #   end
    #   
    #   Rucola::FSEvents.start_watching('/var/log/system.log', '/var/log/secure.log', :since => last_id, :latency => 5) do
    #     Growl.notify("Something was added to your log files!")
    #   end
    #
    # Note that the method also returns the FSEvents object. This enables you to control the event stream if you want to.
    #
    #   fsevents = Rucola::FSEvents.start_watching('/Volumes') do |events|
    #     events.each { |event| Growl.notify("Volume changes: #{event.files.to_sentence}") }
    #   end
    #   fsevents.stop
    def self.start_watching(*params, &block)
      fsevents = new(*params, &block)
      fsevents.create_stream
      fsevents.start
      fsevents
    end

    # Creates a new FSEvents `watchdog` object. You can specify a list of paths to watch and options to control the
    # behaviour of the watchdog. The block you pass serves as a callback when an event is generated on one of the
    # specified paths.
    #
    #   fsevents = FSEvents.new('/etc/passwd') { Mailer.send_mail("Someone touched the password file!") }
    #   fsevents.create_stream
    #   fsevents.start
    #
    #   fsevents = FSEvents.new('/home/upload', :since => UploadWatcher.last_event_id) do |events|
    #     events.each do |event|
    #       UploadWatcher.last_event_id = event.id
    #       event.files.each do |file|
    #         UploadWatcher.logfile.append("#{file} was changed")
    #       end
    #     end
    #   end
    #
    # *:since: The service will report events that have happened after the supplied event ID. Never use 0 because that 
    #   will cause every fsevent since the "beginning of time" to be reported. Use OSX::KFSEventStreamEventIdSinceNow
    #   if you want to receive events that have happened after this call. (Default: OSX::KFSEventStreamEventIdSinceNow).
    #   You can find the ID's passed with :since in the events passed to your block.
    # *:latency: Number of seconds to wait until an FSEvent is reported, this allows the service to bundle events. (Default: 0.0)
    #
    # Please refer to the Cocoa documentation for the rest of the options.
    def initialize(*params, &block)
      raise ArgumentError, 'No callback block was specified.' unless block_given?

      options = params.last.kind_of?(Hash) ? params.pop : {}
      @paths = params.flatten

      paths.each { |path| raise ArgumentError, "The specified path (#{path}) does not exist." unless File.exist?(path) }

      @allocator = options[:allocator] || OSX::KCFAllocatorDefault
      @context = options[:context] || nil
      @since = options[:since] || OSX::KFSEventStreamEventIdSinceNow
      @latency = options[:latency] || 0.0
      @flags = options[:flags] || 0
      @stream = options[:stream] || nil

      @user_callback = block
      @callback = Proc.new do |stream, client_callback_info, number_of_events, paths_pointer, event_flags, event_ids|
        paths_pointer.regard_as('*')
        events = []
        number_of_events.times {|i| events << Rucola::FSEvents::FSEvent.new(self, event_ids[i], paths_pointer[i]) }
        @user_callback.call(events)
      end
    end

    # Create the stream.
    # Raises a Rucola::FSEvents::StreamError if the stream could not be created.
    def create_stream
      @stream = OSX.FSEventStreamCreate(@allocator, @callback, @context, @paths, @since, @latency, @flags)
      raise(StreamError, 'Unable to create FSEvents stream.') unless @stream
      OSX.FSEventStreamScheduleWithRunLoop(@stream, OSX.CFRunLoopGetCurrent, OSX::KCFRunLoopDefaultMode)
    end

    # Start the stream.
    # Raises a Rucola::FSEvents::StreamError if the stream could not be started.
    def start
      raise(StreamError, 'Unable to start FSEvents stream.') unless OSX.FSEventStreamStart(@stream)
    end

    # Stop the stream.
    # You can resume it by calling `start` again.
    def stop
      OSX.FSEventStreamStop(@stream)
    end
  end
end
