require 'net/ssh/loggable'

module Net; module SFTP; module Operations

  # A general purpose uploader module for Net::SFTP. It can upload IO objects,
  # files, and even entire directory trees via SFTP, and provides a flexible
  # progress reporting mechanism.
  #
  # To upload a single file to the remote server, simply specify both the
  # local and remote paths:
  #
  #   uploader = sftp.upload("/path/to/local.txt", "/path/to/remote.txt")
  #
  # By default, this operates asynchronously, so if you want to block until
  # the upload finishes, you can use the 'bang' variant:
  #
  #   sftp.upload!("/path/to/local.txt", "/path/to/remote.txt")
  #
  # Or, if you have multiple uploads that you want to run in parallel, you can
  # employ the #wait method of the returned object:
  #
  #   uploads = %w(file1 file2 file3).map { |f| sftp.upload(f, "remote/#{f}") }
  #   uploads.each { |u| u.wait }
  #
  # To upload an entire directory tree, recursively, simply pass the directory
  # path as the first parameter:
  #
  #   sftp.upload!("/path/to/directory", "/path/to/remote")
  #
  # This will upload "/path/to/directory", it's contents, it's subdirectories,
  # and their contents, recursively, to "/path/to/remote" on the remote server.
  #
  # If you want to send data to a file on the remote server, but the data is
  # in memory, you can pass an IO object and upload it's contents:
  #
  #   require 'stringio'
  #   io = StringIO.new(data)
  #   sftp.upload!(io, "/path/to/remote")
  #
  # The following options are supported:
  #
  # * <tt>:progress</tt> - either a block or an object to act as a progress
  #   callback. See the discussion of "progress monitoring" below.
  # * <tt>:requests</tt> - the number of pending SFTP requests to allow at
  #   any given time. When uploading an entire directory tree recursively,
  #   this will default to 16, otherwise it will default to 2. Setting this
  #   higher might improve throughput. Reducing it will reduce throughput.
  # * <tt>:read_size</tt> - the maximum number of bytes to read at a time
  #   from the source. Increasing this value might improve throughput. It
  #   defaults to 32,000 bytes.
  # * <tt>:name</tt> - the filename to report to the progress monitor when
  #   an IO object is given as +local+. This defaults to "<memory>".
  #
  # == Progress Monitoring
  #
  # Sometimes it is desirable to track the progress of an upload. There are
  # two ways to do this: either using a callback block, or a special custom
  # object.
  #
  # Using a block it's pretty straightforward:
  #
  #   sftp.upload!("local", "remote") do |event, uploader, *args|
  #     case event
  #     when :open then
  #       # args[0] : file metadata
  #       puts "starting upload: #{args[0].local} -> #{args[0].remote} (#{args[0].size} bytes}"
  #     when :put then
  #       # args[0] : file metadata
  #       # args[1] : byte offset in remote file
  #       # args[2] : data being written (as string)
  #       puts "writing #{args[2].length} bytes to #{args[0].remote} starting at #{args[1]}"
  #     when :close then
  #       # args[0] : file metadata
  #       puts "finished with #{args[0].remote}"
  #     when :mkdir then
  #       # args[0] : remote path name
  #       puts "creating directory #{args[0]}"
  #     when :finish then
  #       puts "all done!"
  #   end
  #
  # However, for more complex implementations (e.g., GUI interfaces and such)
  # a block can become cumbersome. In those cases, you can create custom
  # handler objects that respond to certain methods, and then pass your handler
  # to the uploader:
  #
  #   class CustomHandler
  #     def on_open(uploader, file)
  #       puts "starting upload: #{file.local} -> #{file.remote} (#{file.size} bytes)"
  #     end
  #
  #     def on_put(uploader, file, offset, data)
  #       puts "writing #{data.length} bytes to #{file.remote} starting at #{offset}"
  #     end
  #
  #     def on_close(uploader, file)
  #       puts "finished with #{file.remote}"
  #     end
  #
  #     def on_mkdir(uploader, path)
  #       puts "creating directory #{path}"
  #     end
  #
  #     def on_finish(uploader)
  #       puts "all done!"
  #     end
  #   end
  #
  #   sftp.upload!("local", "remote", :progress => CustomHandler.new)
  #
  # If you omit any of those methods, the progress updates for those missing
  # events will be ignored. You can create a catchall method named "call" for
  # those, instead.
  class Upload
    include Net::SSH::Loggable

    # The source of the upload (on the local server)
    attr_reader :local

    # The destination of the upload (on the remote server)
    attr_reader :remote

    # The hash of options that were given when the object was instantiated
    attr_reader :options

    # The SFTP session object used by this upload instance
    attr_reader :sftp

    # The properties hash for this object
    attr_reader :properties

    # Instantiates a new uploader process on top of the given SFTP session.
    # +local+ is either an IO object containing data to upload, or a string
    # identifying a file or directory on the local host. +remote+ is a string
    # identifying the location on the remote host that the upload should
    # target.
    #
    # This will return immediately, and requires that the SSH event loop be
    # run in order to effect the upload. (See #wait.)
    def initialize(sftp, local, remote, options={}, &progress) #:nodoc:
      @sftp = sftp
      @local = local
      @remote = remote
      @progress = progress || options[:progress]
      @options = options
      @properties = options[:properties] || {}
      @active = 0

      self.logger = sftp.logger

      @uploads = []
      @recursive = local.respond_to?(:read) ? false : ::File.directory?(local)

      if recursive?
        @stack = [entries_for(local)]
        @local_cwd = local
        @remote_cwd = remote

        @active += 1
        sftp.mkdir(remote) do |response|
          @active -= 1
          raise StatusException.new(response, "mkdir `#{remote}'") unless response.ok?
          (options[:requests] || RECURSIVE_READERS).to_i.times do
            break unless process_next_entry
          end
        end
      else
        raise ArgumentError, "expected a file to upload" unless local.respond_to?(:read) || ::File.exists?(local)
        @stack = [[local]]
        process_next_entry
      end
    end

    # Returns true if a directory tree is being uploaded, and false if only a
    # single file is being uploaded.
    def recursive?
      @recursive
    end

    # Returns true if the uploader is currently running. When this is false,
    # the uploader has finished processing.
    def active?
      @active > 0 || @stack.any?
    end

    # Forces the transfer to stop.
    def abort!
      @active = 0
      @stack.clear
      @uploads.clear
    end

    # Blocks until the upload has completed.
    def wait
      sftp.loop { active? }
      self
    end

    # Returns the property with the given name. This allows Upload instances
    # to store their own state when used as part of a state machine.
    def [](name)
      @properties[name.to_sym]
    end

    # Sets the given property to the given name. This allows Upload instances
    # to store their own state when used as part of a state machine.
    def []=(name, value)
      @properties[name.to_sym] = value
    end

    private

      #--
      # "ruby -w" hates private attributes, so we have to do this longhand.
      #++

      # The progress handler for this instance. Possibly nil.
      def progress; @progress; end

      # A simple struct for recording metadata about the file currently being
      # uploaded.
      LiveFile = Struct.new(:local, :remote, :io, :size, :handle)

      # The default # of bytes to read from disk at a time.
      DEFAULT_READ_SIZE   = 32_000

      # The number of readers to use when uploading a single file.
      SINGLE_FILE_READERS = 2

      # The number of readers to use when uploading a directory.
      RECURSIVE_READERS   = 16

      # Examines the stack and determines what action to take. This is the
      # starting point of the state machine.
      def process_next_entry
        if @stack.empty?
          if @uploads.any?
            write_next_chunk(@uploads.first)
          elsif !active?
            update_progress(:finish)
          end
          return false
        elsif @stack.last.empty?
          @stack.pop
          @local_cwd = ::File.dirname(@local_cwd)
          @remote_cwd = ::File.dirname(@remote_cwd)
          process_next_entry
        elsif recursive?
          entry = @stack.last.shift
          lpath = ::File.join(@local_cwd, entry)
          rpath = ::File.join(@remote_cwd, entry)

          if ::File.directory?(lpath)
            @stack.push(entries_for(lpath))
            @local_cwd = lpath
            @remote_cwd = rpath

            @active += 1
            update_progress(:mkdir, rpath)
            request = sftp.mkdir(rpath, &method(:on_mkdir))
            request[:dir] = rpath
          else
            open_file(lpath, rpath)
          end
        else
          open_file(@stack.pop.first, remote)
        end
        return true
      end

      # Prepares to send +local+ to +remote+.
      def open_file(local, remote)
        @active += 1

        if local.respond_to?(:read)
          file = local
          name = options[:name] || "<memory>"
        else
          file = ::File.open(local, "rb")
          name = local
        end

        if file.respond_to?(:stat)
          size = file.stat.size
        else
          size = file.size
        end

        metafile = LiveFile.new(name, remote, file, size)
        update_progress(:open, metafile)

        request = sftp.open(remote, "w", &method(:on_open))
        request[:file] = metafile
      end

      # Called when a +mkdir+ request finishes, successfully or otherwise.
      # If the request failed, this will raise a StatusException, otherwise
      # it will call #process_next_entry to continue the state machine.
      def on_mkdir(response)
        @active -= 1
        dir = response.request[:dir]
        raise StatusException.new(response, "mkdir #{dir}") unless response.ok?

        process_next_entry
      end

      # Called when an +open+ request finishes. Raises StatusException if the
      # open failed, otherwise it calls #write_next_chunk to begin sending
      # data to the remote server.
      def on_open(response)
        @active -= 1
        file = response.request[:file]
        raise StatusException.new(response, "open #{file.remote}") unless response.ok?

        file.handle = response[:handle]

        @uploads << file
        write_next_chunk(file)

        if !recursive?
          (options[:requests] || SINGLE_FILE_READERS).to_i.times { write_next_chunk(file) }
        end
      end

      # Called when a +write+ request finishes. Raises StatusException if the
      # write failed, otherwise it calls #write_next_chunk to continue the
      # write.
      def on_write(response)
        @active -= 1
        file = response.request[:file]
        raise StatusException.new(response, "write #{file.remote}") unless response.ok?
        write_next_chunk(file)
      end

      # Called when a +close+ request finishes. Raises a StatusException if the
      # close failed, otherwise it calls #process_next_entry to continue the
      # state machine.
      def on_close(response)
        @active -= 1
        file = response.request[:file]
        raise StatusException.new(response, "close #{file.remote}") unless response.ok?
        process_next_entry
      end

      # Attempts to send the next chunk from the given file (where +file+ is
      # a LiveFile instance).
      def write_next_chunk(file)
        if file.io.nil?
          process_next_entry
        else
          @active += 1
          offset = file.io.pos
          data = file.io.read(options[:read_size] || DEFAULT_READ_SIZE)
          if data.nil?
            update_progress(:close, file)
            request = sftp.close(file.handle, &method(:on_close))
            request[:file] = file
            file.io.close
            file.io = nil
            @uploads.delete(file)
          else
            update_progress(:put, file, offset, data)
            request = sftp.write(file.handle, offset, data, &method(:on_write))
            request[:file] = file
          end
        end
      end

      # Returns all directory entries for the given path, removing the '.'
      # and '..' relative paths.
      def entries_for(local)
        ::Dir.entries(local).reject { |v| %w(. ..).include?(v) }
      end

      # Attempts to notify the progress monitor (if one was given) about
      # progress made for the given event.
      def update_progress(event, *args)
        on = "on_#{event}"
        if progress.respond_to?(on)
          progress.send(on, self, *args)
        elsif progress.respond_to?(:call)
          progress.call(event, self, *args)
        end
      end
  end

end; end; end
