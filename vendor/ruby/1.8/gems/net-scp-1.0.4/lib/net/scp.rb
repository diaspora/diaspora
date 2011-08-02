require 'stringio'
require 'shellwords'

require 'net/ssh'
require 'net/scp/errors'
require 'net/scp/upload'
require 'net/scp/download'

module Net

  # Net::SCP implements the SCP (Secure CoPy) client protocol, allowing Ruby
  # programs to securely and programmatically transfer individual files or
  # entire directory trees to and from remote servers. It provides support for
  # multiple simultaneous SCP copies working in parallel over the same
  # connection, as well as for synchronous, serial copies.
  #
  # Basic usage:
  #
  #   require 'net/scp'
  #
  #   Net::SCP.start("remote.host", "username", :password => "passwd") do |scp|
  #     # synchronous (blocking) upload; call blocks until upload completes
  #     scp.upload! "/local/path", "/remote/path"
  #
  #     # asynchronous upload; call returns immediately and requires SSH
  #     # event loop to run
  #     channel = scp.upload("/local/path", "/remote/path")
  #     channel.wait
  #   end
  #
  # Net::SCP also provides an open-uri tie-in, so you can use the Kernel#open
  # method to open and read a remote file:
  #
  #   # if you just want to parse SCP URL's:
  #   require 'uri/scp'
  #   url = URI.parse("scp://user@remote.host/path/to/file")
  #
  #   # if you want to read from a URL voa SCP:
  #   require 'uri/open-scp'
  #   puts open("scp://user@remote.host/path/to/file").read
  #
  # Lastly, Net::SCP adds a method to the Net::SSH::Connection::Session class,
  # allowing you to easily grab a Net::SCP reference from an existing Net::SSH
  # session:
  #
  #   require 'net/ssh'
  #   require 'net/scp'
  #
  #   Net::SSH.start("remote.host", "username", :password => "passwd") do |ssh|
  #     ssh.scp.download! "/remote/path", "/local/path"
  #   end
  #
  # == Progress Reporting
  #
  # By default, uploading and downloading proceed silently, without any
  # outword indication of their progress. For long running uploads or downloads
  # (and especially in interactive environments) it is desirable to report
  # to the user the progress of the current operation.
  #
  # To receive progress reports for the current operation, just pass a block
  # to #upload or #download (or one of their variants):
  #
  #   scp.upload!("/path/to/local", "/path/to/remote") do |ch, name, sent, total|
  #     puts "#{name}: #{sent}/#{total}"
  #   end
  #
  # Whenever a new chunk of data is recieved for or sent to a file, the callback
  # will be invoked, indicating the name of the file (local for downloads,
  # remote for uploads), the number of bytes that have been sent or received
  # so far for the file, and the size of the file.
  #
  #--
  # = Protocol Description
  #
  # Although this information has zero relevance to consumers of the Net::SCP
  # library, I'm documenting it here so that anyone else looking for documentation
  # of the SCP protocol won't be left high-and-dry like I was. The following is
  # reversed engineered from the OpenSSH SCP implementation, and so may
  # contain errors. You have been warned!
  #
  # The first step is to invoke the "scp" command on the server. It accepts
  # the following parameters, which must be set correctly to avoid errors:
  #
  # * "-t" -- tells the remote scp process that data will be sent "to" it,
  #   e.g., that data will be uploaded and it should initialize itself
  #   accordingly.
  # * "-f" -- tells the remote scp process that data should come "from" it,
  #   e.g., that data will be downloaded and it should initialize itself
  #   accordingly.
  # * "-v" -- verbose mode; the remote scp process should chatter about what
  #   it is doing via stderr.
  # * "-p" -- preserve timestamps. 'T' directives (see below) should be/will
  #   be sent to indicate the modification and access times of each file.
  # * "-r" -- recursive transfers should be allowed. Without this, it is an
  #   error to upload or download a directory.
  #
  # After those flags, the name of the remote file/directory should be passed
  # as the sole non-switch argument to scp.
  #
  # Then the fun begins. If you're doing a download, enter the download_start_state.
  # Otherwise, look for upload_start_state.
  #
  # == Net::SCP::Download#download_start_state
  #
  # This is the start state for downloads. It simply sends a 0-byte to the
  # server. The next state is Net::SCP::Download#read_directive_state.
  #
  # == Net::SCP::Upload#upload_start_state
  #
  # Sets up the initial upload scaffolding and waits for a 0-byte from the
  # server, and then switches to Net::SCP::Upload#upload_current_state.
  #
  # == Net::SCP::Download#read_directive_state
  #
  # Reads a directive line from the input. The following directives are
  # recognized:
  #
  # * T%d %d %d %d -- a "times" packet. Indicates that the next file to be
  #   downloaded must have mtime/usec/atime/usec attributes preserved.
  # * D%o %d %s -- a directory change. The process is changing to a directory
  #   with the given permissions/size/name, and the recipient should create
  #   a directory with the same name and permissions. Subsequent files and
  #   directories will be children of this directory, until a matching 'E'
  #   directive.
  # * C%o %d %s -- a file is being sent next. The file will have the given
  #   permissions/size/name. Immediately following this line, +size+ bytes
  #   will be sent, raw.
  # * E -- terminator directive. Indicates the end of a directory, and subsequent
  #   files and directories should be received by the parent of the current
  #   directory.
  #
  # If a 'C' directive is received, we switch over to
  # Net::SCP::Download#read_data_state. If an 'E' directive is received, and
  # there is no parent directory, we switch over to Net::SCP#finish_state.
  #
  # Regardless of what the next state is, we send a 0-byte to the server
  # before moving to the next state.
  #
  # == Net::SCP::Download#read_data_state
  #
  # Bytes are read to satisfy the size of the incoming file. When all pending
  # data has been read, we wait for the server to send a 0-byte, and then we
  # switch to the Net::SCP::Download#finish_read_state.
  #
  # == Net::SCP::Download#finish_read_state
  #
  # We sent a 0-byte to the server to indicate that the file was successfully
  # received. If there is no parent directory, then we're downloading a single
  # file and we switch to Net::SCP#finish_state. Otherwise we jump back to the
  # Net::SCP::Download#read_directive state to see what we get to download next.
  #
  # == Net::SCP::Upload#upload_current_state
  #
  # If the current item is a file, send a file. Sending a file starts with a
  # 'T' directive (if :preserve is true), then a wait for the server to respond,
  # and then a 'C' directive, and then a wait for the server to respond, and
  # then a jump to Net::SCP::Upload#send_data_state.
  #
  # If current item is a directory, send a 'D' directive, and wait for the
  # server to respond with a 0-byte. Then jump to Net::SCP::Upload#next_item_state.
  #
  # == Net::SCP::Upload#send_data_state
  #
  # Reads and sends the next chunk of data to the server. The state machine
  # remains in this state until all data has been sent, at which point we
  # send a 0-byte to the server, and wait for the server to respond with a
  # 0-byte of its own. Then we jump back to Net::SCP::Upload#next_item_state.
  #
  # == Net::SCP::Upload#next_item_state
  #
  # If there is nothing left to upload, and there is no parent directory,
  # jump to Net::SCP#finish_state.
  #
  # If there is nothing left to upload from the current directory, send an
  # 'E' directive and wait for the server to respond with a 0-byte. Then go
  # to Net::SCP::Upload#next_item_state.
  #
  # Otherwise, set the current upload source and go to
  # Net::SCP::Upload#upload_current_state.
  #
  # == Net::SCP#finish_state
  #
  # Tells the server that no more data is forthcoming from this end of the
  # pipe (via Net::SSH::Connection::Channel#eof!) and leaves the pipe to drain.
  # It will be terminated when the remote process closes with an exit status
  # of zero.
  #++
  class SCP
    include Net::SSH::Loggable
    include Upload, Download

    # Starts up a new SSH connection and instantiates a new SCP session on 
    # top of it. If a block is given, the SCP session is yielded, and the
    # SSH session is closed automatically when the block terminates. If no
    # block is given, the SCP session is returned.
    def self.start(host, username, options={})
      session = Net::SSH.start(host, username, options)
      scp = new(session)

      if block_given?
        begin
          yield scp
          session.loop
        ensure
          session.close
        end
      else
        return scp
      end
    end

    # Starts up a new SSH connection using the +host+ and +username+ parameters,
    # instantiates a new SCP session on top of it, and then begins an
    # upload from +local+ to +remote+. If the +options+ hash includes an
    # :ssh key, the value for that will be passed to the SSH connection as
    # options (e.g., to set the password, etc.). All other options are passed
    # to the #upload! method. If a block is given, it will be used to report
    # progress (see "Progress Reporting", under Net::SCP).
    def self.upload!(host, username, local, remote, options={}, &progress)
      options = options.dup
      start(host, username, options.delete(:ssh) || {}) do |scp|
        scp.upload!(local, remote, options, &progress)
      end
    end

    # Starts up a new SSH connection using the +host+ and +username+ parameters,
    # instantiates a new SCP session on top of it, and then begins a
    # download from +remote+ to +local+. If the +options+ hash includes an
    # :ssh key, the value for that will be passed to the SSH connection as
    # options (e.g., to set the password, etc.). All other options are passed
    # to the #download! method. If a block is given, it will be used to report
    # progress (see "Progress Reporting", under Net::SCP).
    def self.download!(host, username, remote, local=nil, options={}, &progress)
      options = options.dup
      start(host, username, options.delete(:ssh) || {}) do |scp|
        return scp.download!(remote, local, options, &progress)
      end
    end

    # The underlying Net::SSH session that acts as transport for the SCP
    # packets.
    attr_reader :session

    # Creates a new Net::SCP session on top of the given Net::SSH +session+
    # object.
    def initialize(session)
      @session = session
      self.logger = session.logger
    end

    # Inititiate a synchronous (non-blocking) upload from +local+ to +remote+.
    # The following options are recognized:
    #
    # * :recursive - the +local+ parameter refers to a local directory, which
    #   should be uploaded to a new directory named +remote+ on the remote
    #   server.
    # * :preserve - the atime and mtime of the file should be preserved.
    # * :verbose - the process should result in verbose output on the server
    #   end (useful for debugging).
    # * :chunk_size - the size of each "chunk" that should be sent. Defaults
    #   to 2048. Changing this value may improve throughput at the expense
    #   of decreasing interactivity.
    #
    # This method will return immediately, returning the Net::SSH::Connection::Channel
    # object that will support the upload. To wait for the upload to finish,
    # you can either call the #wait method on the channel, or otherwise run
    # the Net::SSH event loop until the channel's #active? method returns false.
    #
    #   channel = scp.upload("/local/path", "/remote/path")
    #   channel.wait
    def upload(local, remote, options={}, &progress)
      start_command(:upload, local, remote, options, &progress)
    end

    # Same as #upload, but blocks until the upload finishes. Identical to
    # calling #upload and then calling the #wait method on the channel object
    # that is returned. The return value is not defined.
    def upload!(local, remote, options={}, &progress)
      upload(local, remote, options, &progress).wait
    end

    # Inititiate a synchronous (non-blocking) download from +remote+ to +local+.
    # The following options are recognized:
    #
    # * :recursive - the +remote+ parameter refers to a remote directory, which
    #   should be downloaded to a new directory named +local+ on the local
    #   machine.
    # * :preserve - the atime and mtime of the file should be preserved.
    # * :verbose - the process should result in verbose output on the server
    #   end (useful for debugging).
    # 
    # This method will return immediately, returning the Net::SSH::Connection::Channel
    # object that will support the download. To wait for the download to finish,
    # you can either call the #wait method on the channel, or otherwise run
    # the Net::SSH event loop until the channel's #active? method returns false.
    #
    #   channel = scp.download("/remote/path", "/local/path")
    #   channel.wait
    def download(remote, local, options={}, &progress)
      start_command(:download, local, remote, options, &progress)
    end

    # Same as #download, but blocks until the download finishes. Identical to
    # calling #download and then calling the #wait method on the channel
    # object that is returned.
    #
    #   scp.download!("/remote/path", "/local/path")
    #
    # If +local+ is nil, and the download is not recursive (e.g., it is downloading
    # only a single file), the file will be downloaded to an in-memory buffer
    # and the resulting string returned.
    #
    #   data = download!("/remote/path")
    def download!(remote, local=nil, options={}, &progress)
      destination = local ? local : StringIO.new
      download(remote, destination, options, &progress).wait
      local ? true : destination.string
    end

    private

      # Constructs the scp command line needed to initiate and SCP session
      # for the given +mode+ (:upload or :download) and with the given options
      # (:verbose, :recursive, :preserve). Returns the command-line as a
      # string, ready to execute.
      def scp_command(mode, options)
        command = "scp "
        command << (mode == :upload ? "-t" : "-f")
        command << " -v" if options[:verbose]
        command << " -r" if options[:recursive]
        command << " -p" if options[:preserve]
        command
      end

      # Opens a new SSH channel and executes the necessary SCP command over
      # it (see #scp_command). It then sets up the necessary callbacks, and
      # sets up a state machine to use to process the upload or download.
      # (See Net::SCP::Upload and Net::SCP::Download).
      def start_command(mode, local, remote, options={}, &callback)
        session.open_channel do |channel|
          command = "#{scp_command(mode, options)} #{shellescape remote}"
          channel.exec(command) do |ch, success|
            if success
              channel[:local   ] = local
              channel[:remote  ] = remote
              channel[:options ] = options.dup
              channel[:callback] = callback
              channel[:buffer  ] = Net::SSH::Buffer.new
              channel[:state   ] = "#{mode}_start"
              channel[:stack   ] = []

              channel.on_close                  { |ch| raise Net::SCP::Error, "SCP did not finish successfully (#{ch[:exit]})" if ch[:exit] != 0 }
              channel.on_data                   { |ch, data| channel[:buffer].append(data) }
              channel.on_extended_data          { |ch, type, data| debug { data.chomp } }
              channel.on_request("exit-status") { |ch, data| channel[:exit] = data.read_long }
              channel.on_process                { send("#{channel[:state]}_state", channel) }
            else
              channel.close
              raise Net::SCP::Error, "could not exec scp on the remote host"
            end
          end
        end
      end

      # Causes the state machine to enter the "await response" state, where
      # things just pause until the server replies with a 0 (see
      # #await_response_state), at which point the state machine will pick up
      # at +next_state+ and continue processing.
      def await_response(channel, next_state)
        channel[:state] = :await_response
        channel[:next ] = next_state.to_sym
        # check right away, to see if the response is immediately available
        await_response_state(channel)
      end

      # The action invoked while the state machine remains in the "await
      # response" state. As long as there is no data ready to process, the
      # machine will remain in this state. As soon as the server replies with
      # an integer 0 as the only byte, the state machine is kicked into the
      # next state (see +await_response+). If the response is not a 0, an
      # exception is raised.
      def await_response_state(channel)
        return if channel[:buffer].available == 0
        c = channel[:buffer].read_byte
        raise "#{c.chr}#{channel[:buffer].read}" if c != 0
        channel[:next], channel[:state] = nil, channel[:next]
        send("#{channel[:state]}_state", channel)
      end

      # The action invoked when the state machine is in the "finish" state.
      # It just tells the server not to expect any more data from this end
      # of the pipe, and allows the pipe to drain until the server closes it.
      def finish_state(channel)
        channel.eof!
      end

      # Invoked to report progress back to the client. If a callback was not
      # set, this does nothing.
      def progress_callback(channel, name, sent, total)
        channel[:callback].call(channel, name, sent, total) if channel[:callback]
      end

      # Imported from ruby 1.9.2 shellwords.rb
      def shellescape(str)
        # ruby 1.8.7+ implements String#shellescape
        return str.shellescape if str.respond_to? :shellescape

        # An empty argument will be skipped, so return empty quotes.
        return "''" if str.empty?

        str = str.dup

        # Process as a single byte sequence because not all shell
        # implementations are multibyte aware.
        str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

        # A LF cannot be escaped with a backslash because a backslash + LF
        # combo is regarded as line continuation and simply ignored.
        str.gsub!(/\n/, "'\n'")

        return str
      end
  end
end

class Net::SSH::Connection::Session
  # Provides a convenient way to initialize a SCP session given a Net::SSH
  # session. Returns the Net::SCP instance, ready to use.
  def scp
    @scp ||= Net::SCP.new(self)
  end
end
