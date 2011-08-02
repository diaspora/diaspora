require 'net/ssh'
require 'net/sftp/constants'
require 'net/sftp/errors'
require 'net/sftp/protocol'
require 'net/sftp/request'
require 'net/sftp/operations/dir'
require 'net/sftp/operations/upload'
require 'net/sftp/operations/download'
require 'net/sftp/operations/file_factory'

module Net; module SFTP

  # The Session class encapsulates a single SFTP channel on a Net::SSH
  # connection. Instances of this class are what most applications will
  # interact with most, as it provides access to both low-level (mkdir,
  # rename, remove, symlink, etc.) and high-level (upload, download, etc.)
  # SFTP operations.
  #
  # Although Session makes it easy to do SFTP operations serially, you can
  # also set up multiple operations to be done in parallel, too, without
  # needing to resort to threading. You merely need to fire off the requests,
  # and then run the event loop until all of the requests have completed:
  #
  #   handle1 = sftp.open!("/path/to/file1")
  #   handle2 = sftp.open!("/path/to/file2")
  #
  #   r1 = sftp.read(handle1, 0, 1024)
  #   r2 = sftp.read(handle2, 0, 1024)
  #   sftp.loop { [r1, r2].any? { |r| r.pending? } }
  #
  #   puts "chunk #1: #{r1.response[:data]}"
  #   puts "chunk #2: #{r2.response[:data]}"
  #
  # By passing blocks to the operations, you can set up powerful state
  # machines, to fire off subsequent operations. In fact, the Net::SFTP::Operations::Upload
  # and Net::SFTP::Operations::Download classes set up such state machines, so that
  # multiple uploads and/or downloads can be running simultaneously.
  #
  # The convention with the names of the operations is as follows: if the method
  # name ends with an exclamation mark, like #read!, it will be synchronous
  # (e.g., it will block until the server responds). Methods without an
  # exclamation mark (e.g. #read) are asynchronous, and return before the
  # server has responded. You will need to make sure the SSH event loop is
  # run in order to process these requests. (See #loop.)
  class Session
    include Net::SSH::Loggable
    include Net::SFTP::Constants::PacketTypes

    # The highest protocol version supported by the Net::SFTP library.
    HIGHEST_PROTOCOL_VERSION_SUPPORTED = 6

    # A reference to the Net::SSH session object that powers this SFTP session.
    attr_reader :session

    # The Net::SSH::Connection::Channel object that the SFTP session is being
    # processed by.
    attr_reader :channel

    # The state of the SFTP connection. It will be :opening, :subsystem, :init,
    # :open, or :closed.
    attr_reader :state

    # The protocol instance being used by this SFTP session. Useful for
    # querying the protocol version in effect.
    attr_reader :protocol

    # The hash of pending requests. Any requests that have been sent and which
    # the server has not yet responded to will be represented here.
    attr_reader :pending_requests

    # Creates a new Net::SFTP instance atop the given Net::SSH connection.
    # This will return immediately, before the SFTP connection has been properly
    # initialized. Once the connection is ready, the given block will be called.
    # If you want to block until the connection has been initialized, try this:
    #
    #   sftp = Net::SFTP::Session.new(ssh)
    #   sftp.loop { sftp.opening? }
    def initialize(session, &block)
      @session    = session
      @input      = Net::SSH::Buffer.new
      self.logger = session.logger
      @state      = :closed

      connect(&block)
    end

    public # high-level SFTP operations

      # Initiates an upload from +local+ to +remote+, asynchronously. This
      # method will return a new Net::SFTP::Operations::Upload instance, and requires
      # the event loop to be run in order for the upload to progress. See
      # Net::SFTP::Operations::Upload for a full discussion of how this method can be
      # used.
      #
      #   uploader = sftp.upload("/local/path", "/remote/path")
      #   uploader.wait
      def upload(local, remote, options={}, &block)
        Operations::Upload.new(self, local, remote, options, &block)
      end

      # Identical to #upload, but blocks until the upload is complete.
      def upload!(local, remote, options={}, &block)
        upload(local, remote, options, &block).wait
      end

      # Initiates a download from +remote+ to +local+, asynchronously. This
      # method will return a new Net::SFTP::Operations::Download instance, and requires
      # that the event loop be run in order for the download to progress. See
      # Net::SFTP::Operations::Download for a full discussion of hos this method can be
      # used.
      #
      #   download = sftp.download("/remote/path", "/local/path")
      #   download.wait
      def download(remote, local, options={}, &block)
        Operations::Download.new(self, local, remote, options, &block)
      end

      # Identical to #download, but blocks until the download is complete.
      # If +local+ is omitted, downloads the file to an in-memory buffer
      # and returns the result as a string; otherwise, returns the
      # Net::SFTP::Operations::Download instance.
      def download!(remote, local=nil, options={}, &block)
        require 'stringio' unless defined?(StringIO)
        destination = local || StringIO.new
        result = download(remote, destination, options, &block).wait
        local ? result : destination.string
      end

      # Returns an Net::SFTP::Operations::FileFactory instance, which can be used to
      # mimic synchronous, IO-like file operations on a remote file via
      # SFTP.
      #
      #   sftp.file.open("/path/to/file") do |file|
      #     while line = file.gets
      #       puts line
      #     end
      #   end
      #
      # See Net::SFTP::Operations::FileFactory and Net::SFTP::Operations::File for more details.
      def file
        @file ||= Operations::FileFactory.new(self)
      end

      # Returns a Net::SFTP::Operations::Dir instance, which can be used to
      # conveniently iterate over and search directories on the remote server.
      #
      #  sftp.dir.glob("/base/path", "*/**/*.rb") do |entry|
      #    p entry.name
      #  end
      #
      # See Net::SFTP::Operations::Dir for a more detailed discussion of how
      # to use this.
      def dir
        @dir ||= Operations::Dir.new(self)
      end

    public # low-level SFTP operations

      # :call-seq:
      #   open(path, flags="r", options={}) -> request
      #   open(path, flags="r", options={}) { |response| ... } -> request
      #
      # Opens a file on the remote server. The +flags+ parameter determines
      # how the flag is open, and accepts the same format as IO#open (e.g.,
      # either a string like "r" or "w", or a combination of the IO constants).
      # The +options+ parameter is a hash of attributes to be associated
      # with the file, and varies greatly depending on the SFTP protocol
      # version in use, but some (like :permissions) are always available.
      #
      # Returns immediately with a Request object. If a block is given, it will
      # be invoked when the server responds, with a Response object as the only
      # parameter. The :handle property of the response is the handle of the
      # opened file, and may be passed to other methods (like #close, #read,
      # #write, and so forth).
      #
      #   sftp.open("/path/to/file") do |response|
      #     raise "fail!" unless response.ok?
      #     sftp.close(response[:handle])
      #   end
      #   sftp.loop
      def open(path, flags="r", options={}, &callback)
        request :open, path, flags, options, &callback
      end

      # Identical to #open, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return the handle of the newly opened file.
      #
      #   handle = sftp.open!("/path/to/file")
      def open!(path, flags="r", options={}, &callback)
        wait_for(open(path, flags, options, &callback), :handle)
      end

      # :call-seq:
      #   close(handle) -> request
      #   close(handle) { |response| ... } -> request
      #
      # Closes an open handle, whether obtained via #open, or #opendir. Returns
      # immediately with a Request object. If a block is given, it will be
      # invoked when the server responds.
      #
      #   sftp.open("/path/to/file") do |response|
      #     raise "fail!" unless response.ok?
      #     sftp.close(response[:handle])
      #   end
      #   sftp.loop
      def close(handle, &callback)
        request :close, handle, &callback
      end

      # Identical to #close, but blocks until the server responds. It will
      # raise a StatusException if the request was unsuccessful. Otherwise,
      # it returns the Response object for this request.
      #
      #   sftp.close!(handle)
      def close!(handle, &callback)
        wait_for(close(handle, &callback))
      end

      # :call-seq:
      #   read(handle, offset, length) -> request
      #   read(handle, offset, length) { |response| ... } -> request
      #
      # Requests that +length+ bytes, starting at +offset+ bytes from the
      # beginning of the file, be read from the file identified by
      # +handle+. (The +handle+ should be a value obtained via the #open
      # method.)  Returns immediately with a Request object. If a block is
      # given, it will be invoked when the server responds.
      #
      # The :data property of the response will contain the requested data,
      # assuming the call was successful.
      #
      #   request = sftp.read(handle, 0, 1024) do |response|
      #     if response.eof?
      #       puts "end of file reached before reading any data"
      #     elsif !response.ok?
      #       puts "error (#{response})"
      #     else
      #       print(response[:data])
      #     end
      #   end
      #   request.wait
      #
      # To read an entire file will usually require multiple calls to #read,
      # unless you know in advance how large the file is.
      def read(handle, offset, length, &callback)
        request :read, handle, offset, length, &callback
      end

      # Identical to #read, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. If the end of the file
      # was reached, +nil+ will be returned. Otherwise, it returns the data that
      # was read, as a String.
      #
      #   data = sftp.read!(handle, 0, 1024)
      def read!(handle, offset, length, &callback)
        wait_for(read(handle, offset, length, &callback), :data)
      end

      # :call-seq:
      #   write(handle, offset, data) -> request
      #   write(handle, offset, data) { |response| ... } -> request
      #
      # Requests that +data+ be written to the file identified by +handle+,
      # starting at +offset+ bytes from the start of the file. The file must
      # have been opened for writing via #open. Returns immediately with a
      # Request object. If a block is given, it will be invoked when the
      # server responds.
      #
      #   request = sftp.write(handle, 0, "hello, world!\n")
      #   request.wait
      def write(handle, offset, data, &callback)
        request :write, handle, offset, data, &callback
      end

      # Identical to #write, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful, or the end of the file
      # was reached. Otherwise, it returns the Response object for this request.
      #
      #   sftp.write!(handle, 0, "hello, world!\n")
      def write!(handle, offset, data, &callback)
        wait_for(write(handle, offset, data, &callback))
      end

      # :call-seq:
      #   lstat(path, flags=nil) -> request
      #   lstat(path, flags=nil) { |response| ... } -> request
      #
      # This method is identical to the #stat method, with the exception that
      # it will not follow symbolic links (thus allowing you to stat the
      # link itself, rather than what it refers to). The +flags+ parameter
      # is not used in SFTP protocol versions prior to 4, and will be ignored
      # in those versions of the protocol that do not use it. For those that
      # do, however, you may provide hints as to which file proprties you wish
      # to query (e.g., if all you want is permissions, you could pass the
      # Net::SFTP::Protocol::V04::Attributes::F_PERMISSIONS flag as the value
      # for the +flags+ parameter).
      #
      # The method returns immediately with a Request object. If a block is given,
      # it will be invoked when the server responds. The :attrs property of
      # the response will contain an Attributes instance appropriate for the
      # the protocol version (see Protocol::V01::Attributes, Protocol::V04::Attributes,
      # and Protocol::V06::Attributes).
      #
      #   request = sftp.lstat("/path/to/file") do |response|
      #     raise "fail!" unless response.ok?
      #     puts "permissions: %04o" % response[:attrs].permissions
      #   end
      #   request.wait
      def lstat(path, flags=nil, &callback)
        request :lstat, path, flags, &callback
      end

      # Identical to the #lstat method, but blocks until the server responds.
      # It will raise a StatusException if the request was unsuccessful.
      # Otherwise, it will return the attribute object describing the path.
      #
      #   puts sftp.lstat!("/path/to/file").permissions
      def lstat!(path, flags=nil, &callback)
        wait_for(lstat(path, flags, &callback), :attrs)
      end

      # The fstat method is identical to the #stat and #lstat methods, with
      # the exception that it takes a +handle+ as the first parameter, such
      # as would be obtained via the #open or #opendir methods. (See the #lstat
      # method for full documentation).
      def fstat(handle, flags=nil, &callback)
        request :fstat, handle, flags, &callback
      end

      # Identical to the #fstat method, but blocks until the server responds.
      # It will raise a StatusException if the request was unsuccessful.
      # Otherwise, it will return the attribute object describing the path.
      #
      #   puts sftp.fstat!(handle).permissions
      def fstat!(handle, flags=nil, &callback)
        wait_for(fstat(handle, flags, &callback), :attrs)
      end

      # :call-seq:
      #    setstat(path, attrs) -> request
      #    setstat(path, attrs) { |response| ... } -> request
      #
      # This method may be used to set file metadata (such as permissions, or
      # user/group information) on a remote file. The exact metadata that may
      # be tweaked is dependent on the SFTP protocol version in use, but in
      # general you may set at least the permissions, user, and group. (See
      # Protocol::V01::Attributes, Protocol::V04::Attributes, and Protocol::V06::Attributes
      # for the full lists of attributes that may be set for the different
      # protocols.)
      #
      # The +attrs+ parameter is a hash, where the keys are symbols identifying
      # the attributes to set.
      #
      # The method returns immediately with a Request object. If a block is given,
      # it will be invoked when the server responds.
      #
      #   request = sftp.setstat("/path/to/file", :permissions => 0644)
      #   request.wait
      #   puts "success: #{request.response.ok?}"
      def setstat(path, attrs, &callback)
        request :setstat, path, attrs, &callback
      end

      # Identical to the #setstat method, but blocks until the server responds.
      # It will raise a StatusException if the request was unsuccessful.
      # Otherwise, it will return the Response object for the request.
      #
      #   sftp.setstat!("/path/to/file", :permissions => 0644)
      def setstat!(path, attrs, &callback)
        wait_for(setstat(path, attrs, &callback))
      end

      # The fsetstat method is identical to the #setstat method, with the
      # exception that it takes a +handle+ as the first parameter, such as
      # would be obtained via the #open or #opendir methods. (See the
      # #setstat method for full documentation.)
      def fsetstat(handle, attrs, &callback)
        request :fsetstat, handle, attrs, &callback
      end

      # Identical to the #fsetstat method, but blocks until the server responds.
      # It will raise a StatusException if the request was unsuccessful.
      # Otherwise, it will return the Response object for the request.
      #
      #   sftp.fsetstat!(handle, :permissions => 0644)
      def fsetstat!(handle, attrs, &callback)
        wait_for(fsetstat(handle, attrs, &callback))
      end

      # :call-seq:
      #   opendir(path) -> request
      #   opendir(path) { |response| ... } -> request
      #
      # Attempts to open a directory on the remote host for reading. Once the
      # handle is obtained, directory entries may be retrieved using the
      # #readdir method. The method returns immediately with a Request object.
      # If a block is given, it will be invoked when the server responds.
      #
      #   sftp.opendir("/path/to/directory") do |response|
      #     raise "fail!" unless response.ok?
      #     sftp.close(response[:handle])
      #   end
      #   sftp.loop
      def opendir(path, &callback)
        request :opendir, path, &callback
      end

      # Identical to #opendir, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return a handle to the given path.
      #
      #   handle = sftp.opendir!("/path/to/directory")
      def opendir!(path, &callback)
        wait_for(opendir(path, &callback), :handle)
      end

      # :call-seq:
      #   readdir(handle) -> request
      #   raeddir(handle) { |response| ... } -> request
      #
      # Reads a set of entries from the given directory handle (which must
      # have been obtained via #opendir). If the response is EOF, then there
      # are no more entries in the directory. Otherwise, the entries will be
      # in the :names property of the response:
      #
      #   loop do
      #     request = sftp.readdir(handle).wait
      #     break if request.response.eof?
      #     raise "fail!" unless request.response.ok?
      #     request.response[:names].each do |entry|
      #        puts entry.name
      #     end
      #   end
      #
      # See also Protocol::V01::Name and Protocol::V04::Name for the specific
      # properties of each individual entry (which vary based on the SFTP
      # protocol version in use).
      def readdir(handle, &callback)
        request :readdir, handle, &callback
      end

      # Identical to #readdir, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return nil if there were no more names to read, or an array of name
      # entries.
      #
      #   while (entries = sftp.readdir!(handle)) do
      #     entries.each { |entry| puts(entry.name) }
      #   end
      def readdir!(handle, &callback)
        wait_for(readdir(handle, &callback), :names)
      end

      # :call-seq:
      #   remove(filename) -> request
      #   remove(filename) { |response| ... } -> request
      #
      # Attempts to remove the given file from the remote file system. Returns
      # immediately with a Request object. If a block is given, the block will
      # be invoked when the server responds, and will be passed a Response
      # object.
      #
      #   sftp.remove("/path/to/file").wait
      def remove(filename, &callback)
        request :remove, filename, &callback
      end

      # Identical to #remove, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return the Response object for the request.
      #
      #   sftp.remove!("/path/to/file")
      def remove!(filename, &callback)
        wait_for(remove(filename, &callback))
      end

      # :call-seq:
      #   mkdir(path, attrs={}) -> request
      #   mkdir(path, attrs={}) { |response| ... } -> request
      #
      # Creates the named directory on the remote server. If an attribute hash
      # is given, it must map to the set of attributes supported by the version
      # of the SFTP protocol in use. (See Protocol::V01::Attributes,
      # Protocol::V04::Attributes, and Protocol::V06::Attributes.)
      #
      #   sftp.mkdir("/path/to/directory", :permissions => 0550).wait
      def mkdir(path, attrs={}, &callback)
        request :mkdir, path, attrs, &callback
      end

      # Identical to #mkdir, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return the Response object for the request.
      #
      #   sftp.mkdir!("/path/to/directory", :permissions => 0550)
      def mkdir!(path, attrs={}, &callback)
        wait_for(mkdir(path, attrs, &callback))
      end

      # :call-seq:
      #   rmdir(path) -> request
      #   rmdir(path) { |response| ... } -> request
      #
      # Removes the named directory on the remote server. The directory must
      # be empty before it can be removed.
      #
      #   sftp.rmdir("/path/to/directory").wait
      def rmdir(path, &callback)
        request :rmdir, path, &callback
      end

      # Identical to #rmdir, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return the Response object for the request.
      #
      #   sftp.rmdir!("/path/to/directory")
      def rmdir!(path, &callback)
        wait_for(rmdir(path, &callback))
      end

      # :call-seq:
      #   realpath(path) -> request
      #   realpath(path) { |response| ... } -> request
      #
      # Tries to canonicalize the given path, turning any given path into an
      # absolute path. This is primarily useful for converting a path with
      # ".." or "." segments into an identical path without those segments.
      # The answer will be in the response's :names attribute, as a
      # one-element array.
      #
      #   request = sftp.realpath("/path/../to/../directory").wait
      #   puts request[:names].first.name
      def realpath(path, &callback)
        request :realpath, path, &callback
      end

      # Identical to #realpath, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return a name object identifying the path.
      #
      #   puts(sftp.realpath!("/path/../to/../directory"))
      def realpath!(path, &callback)
        wait_for(realpath(path, &callback), :names).first
      end

      # Identical to the #lstat method, except that it follows symlinks
      # (e.g., if you give it the path to a symlink, it will stat the target
      # of the symlink rather than the symlink itself). See the #lstat method
      # for full documentation.
      def stat(path, flags=nil, &callback)
        request :stat, path, flags, &callback
      end

      # Identical to #stat, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return an attribute object for the named path.
      #
      #   attrs = sftp.stat!("/path/to/file")
      def stat!(path, flags=nil, &callback)
        wait_for(stat(path, flags, &callback), :attrs)
      end

      # :call-seq:
      #   rename(name, new_name, flags=nil) -> request
      #   rename(name, new_name, flags=nil) { |response| ... } -> request
      #
      # Renames the given file. This operation is only available in SFTP
      # protocol versions two and higher. The +flags+ parameter is ignored
      # in versions prior to 5. In versions 5 and higher, the +flags+
      # parameter can be used to specify how the rename should be performed
      # (atomically, etc.).
      #
      # The following flags are defined in protocol version 5:
      #
      # * 0x0001 - overwrite an existing file if the new name specifies a file
      #   that already exists.
      # * 0x0002 - perform the rewrite atomically.
      # * 0x0004 - allow the server to perform the rename as it prefers.
      def rename(name, new_name, flags=nil, &callback)
        request :rename, name, new_name, flags, &callback
      end

      # Identical to #rename, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return the Response object for the request.
      #
      #   sftp.rename!("/path/to/old", "/path/to/new")
      def rename!(name, new_name, flags=nil, &callback)
        wait_for(rename(name, new_name, flags, &callback))
      end

      # :call-seq:
      #   readlink(path) -> request
      #   readlink(path) { |response| ... } -> request
      #
      # Queries the server for the target of the specified symbolic link.
      # This operation is only available in protocol versions 3 and higher.
      # The response to this request will include a names property, a one-element
      # array naming the target of the symlink.
      #
      #   request = sftp.readlink("/path/to/symlink").wait
      #   puts request.response[:names].first.name
      def readlink(path, &callback)
        request :readlink, path, &callback
      end

      # Identical to #readlink, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return the Name object for the path that the symlink targets.
      #
      #   item = sftp.readlink!("/path/to/symlink")
      def readlink!(path, &callback)
        wait_for(readlink(path, &callback), :names).first
      end

      # :call-seq:
      #   symlink(path, target) -> request
      #   symlink(path, target) { |response| ... } -> request
      #
      # Attempts to create a symlink to +path+ at +target+. This operation
      # is only available in protocol versions 3, 4, and 5, but the Net::SFTP
      # library mimics the symlink behavior in protocol version 6 using the
      # #link method, so it is safe to use this method in protocol version 6.
      #
      #   sftp.symlink("/path/to/file", "/path/to/symlink").wait
      def symlink(path, target, &callback)
        request :symlink, path, target, &callback
      end

      # Identical to #symlink, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return the Response object for the request.
      #
      #   sftp.symlink!("/path/to/file", "/path/to/symlink")
      def symlink!(path, target, &callback)
        wait_for(symlink(path, target, &callback))
      end

      # :call-seq:
      #   link(new_link_path, existing_path, symlink=true) -> request
      #   link(new_link_path, existing_path, symlink=true) { |response| ... } -> request
      #
      # Attempts to create a link, either hard or symbolic. This operation is
      # only available in SFTP protocol versions 6 and higher. If the +symlink+
      # paramter is true, a symbolic link will be created, otherwise a hard
      # link will be created. The link will be named +new_link_path+, and will
      # point to the path +existing_path+.
      #
      #   sftp.link("/path/to/symlink", "/path/to/file", true).wait
      #
      # Note that #link is only available for SFTP protocol 6 and higher. You
      # can use #symlink for protocols 3 and higher.
      def link(new_link_path, existing_path, symlink=true, &callback)
        request :link, new_link_path, existing_path, symlink, &callback
      end

      # Identical to #link, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return the Response object for the request.
      #
      #   sftp.link!("/path/to/symlink", "/path/to/file", true)
      def link!(new_link_path, existing_path, symlink=true, &callback)
        wait_for(link(new_link_path, existing_path, symlink, &callback))
      end

      # :call-seq:
      #   block(handle, offset, length, mask) -> request
      #   block(handle, offset, length, mask) { |response| ... } -> request
      #
      # Creates a byte-range lock on the file specified by the given +handle+.
      # This operation is only available in SFTP protocol versions 6 and
      # higher. The lock may be either mandatory or advisory.
      #
      # The +handle+ parameter is a file handle, as obtained by the #open method.
      #
      # The +offset+ and +length+ parameters describe the location and size of
      # the byte range.
      #
      # The +mask+ describes how the lock should be defined, and consists of
      # some combination of the following bit masks:
      #
      # * 0x0040 - Read lock. The byte range may not be accessed for reading
      #   by via any other handle, though it may be written to.
      # * 0x0080 - Write lock. The byte range may not be written to via any
      #   other handle, though it may be read from.
      # * 0x0100 - Delete lock. No other handle may delete this file.
      # * 0x0200 - Advisory lock. The server need not honor the lock instruction.
      #
      # Once created, the lock may be removed via the #unblock method.
      def block(handle, offset, length, mask, &callback)
        request :block, handle, offset, length, mask, &callback
      end

      # Identical to #block, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return the Response object for the request.
      def block!(handle, offset, length, mask, &callback)
        wait_for(block(handle, offset, length, mask, &callback))
      end

      # :call-seq:
      #   unblock(handle, offset, length) -> request
      #   unblock(handle, offset, length) { |response| ... } -> request
      #
      # Removes a previously created byte-range lock. This operation is only
      # available in protocol versions 6 and higher. The +offset+ and +length+
      # parameters must exactly match those that were given to #block when the
      # lock was acquired.
      def unblock(handle, offset, length, &callback)
        request :unblock, handle, offset, length, &callback
      end

      # Identical to #unblock, but blocks until the server responds. It will raise
      # a StatusException if the request was unsuccessful. Otherwise, it will
      # return the Response object for the request.
      def unblock!(handle, offset, length, &callback)
        wait_for(unblock(handle, offset, length, &callback))
      end

    public # miscellaneous methods

      # Closes the SFTP connection, but not the SSH connection. Blocks until the
      # session has terminated. Once the session has terminated, further operations
      # on this object will result in errors. You can reopen the SFTP session
      # via the #connect method.
      def close_channel
        return unless open?
        channel.close
        loop { !closed? }
      end

      # Returns true if the connection has been initialized.
      def open?
        state == :open
      end

      # Returns true if the connection has been closed.
      def closed?
        state == :closed
      end

      # Returns true if the connection is in the process of being initialized
      # (e.g., it is not closed, but is not yet fully open).
      def opening?
        !(open? || closed?)
      end

      # Attempts to establish an SFTP connection over the SSH session given when
      # this object was instantiated. If the object is already open, this will
      # simply execute the given block (if any), passing the SFTP session itself
      # as argument. If the session is currently being opened, this will add
      # the given block to the list of callbacks, to be executed when the session
      # is fully open.
      #
      # This method does not block, and will return immediately. If you pass a
      # block to it, that block will be invoked when the connection has been
      # fully established. Thus, you can do something like this:
      #
      #   sftp.connect do
      #     puts "open!"
      #   end
      #
      # If you just want to block until the connection is ready, see the #connect!
      # method.
      def connect(&block)
        case state
        when :open
          block.call(self) if block
        when :closed
          @state = :opening
          @channel = session.open_channel(&method(:when_channel_confirmed))
          @packet_length = nil
          @protocol = nil
          @on_ready = Array(block)
        else # opening
          @on_ready << block if block
        end

        self
      end

      # Same as the #connect method, but blocks until the SFTP connection has
      # been fully initialized.
      def connect!(&block)
        connect(&block)
        loop { opening? }
        self
      end

      alias :loop_forever :loop

      # Runs the SSH event loop while the given block returns true. This lets
      # you set up a state machine and then "fire it off". If you do not specify
      # a block, the event loop will run for as long as there are any pending
      # SFTP requests. This makes it easy to do thing like this:
      #
      #   sftp.remove("/path/to/file")
      #   sftp.loop
      def loop(&block)
        block ||= Proc.new { pending_requests.any? }
        session.loop(&block)
      end

      # Formats, constructs, and sends an SFTP packet of the given type and with
      # the given data. This does not block, but merely enqueues the packet for
      # sending and returns.
      #
      # You should probably use the operation methods, rather than building and
      # sending the packet directly. (See #open, #close, etc.)
      def send_packet(type, *args)
        data = Net::SSH::Buffer.from(*args)
        msg = Net::SSH::Buffer.from(:long, data.length+1, :byte, type, :raw, data)
        channel.send_data(msg.to_s)
      end

    private

      #--
      # "ruby -w" hates private attributes, so we have to do this longhand
      #++

      # The input buffer used to accumulate packet data
      def input; @input; end

      # Create and enqueue a new SFTP request of the given type, with the
      # given arguments. Returns a new Request instance that encapsulates the
      # request.
      def request(type, *args, &callback)
        request = Request.new(self, type, protocol.send(type, *args), &callback)
        info { "sending #{type} packet (#{request.id})" }
        pending_requests[request.id] = request
      end

      # Waits for the given request to complete. If the response is
      # EOF, nil is returned. If the response was not successful
      # (e.g., !response.ok?), a StatusException will be raised.
      # If +property+ is given, the corresponding property from the response
      # will be returned; otherwise, the response object itself will be
      # returned.
      def wait_for(request, property=nil)
        request.wait
        if request.response.eof?
          nil
        elsif !request.response.ok?
          raise StatusException.new(request.response)
        elsif property
          request.response[property.to_sym]
        else
          request.response
        end
      end

      # Called when the SSH channel is confirmed as "open" by the server.
      # This is one of the states of the SFTP state machine, and is followed
      # by the #when_subsystem_started state.
      def when_channel_confirmed(channel)
        debug { "requesting sftp subsystem" }
        @state = :subsystem
        channel.subsystem("sftp", &method(:when_subsystem_started))
      end

      # Called when the SSH server confirms that the SFTP subsystem was
      # successfully started. This sets up the appropriate callbacks on the
      # SSH channel and then starts the SFTP protocol version negotiation
      # process.
      def when_subsystem_started(channel, success)
        raise Net::SFTP::Exception, "could not start SFTP subsystem" unless success

        debug { "sftp subsystem successfully started" }
        @state = :init

        channel.on_data { |c,data| input.append(data) }
        channel.on_extended_data { |c,t,data| debug { data } }

        channel.on_close(&method(:when_channel_closed))
        channel.on_process(&method(:when_channel_polled))

        send_packet(FXP_INIT, :long, HIGHEST_PROTOCOL_VERSION_SUPPORTED)
      end

      # Called when the SSH server closes the underlying channel.
      def when_channel_closed(channel)
        debug { "sftp channel closed" }
        @channel = nil
        @state = :closed
      end

      # Called whenever Net::SSH polls the SFTP channel for pending activity.
      # This basically checks the input buffer to see if enough input has been
      # accumulated to handle. If there has, the packet is parsed and
      # dispatched, according to its type (see #do_version and #dispatch_request).
      def when_channel_polled(channel)
        while input.length > 0
          if @packet_length.nil?
            # make sure we've read enough data to tell how long the packet is
            return unless input.length >= 4
            @packet_length = input.read_long
          end

          return unless input.length >= @packet_length
          packet = Net::SFTP::Packet.new(input.read(@packet_length))
          input.consume!
          @packet_length = nil

          debug { "received sftp packet #{packet.type} len #{packet.length}" }

          if packet.type == FXP_VERSION
            do_version(packet)
          else
            dispatch_request(packet)
          end
        end
      end

      # Called to handle FXP_VERSION packets. This performs the SFTP protocol
      # version negotiation, instantiating the appropriate Protocol instance
      # and invoking the callback given to #connect, if any.
      def do_version(packet)
        debug { "negotiating sftp protocol version, mine is #{HIGHEST_PROTOCOL_VERSION_SUPPORTED}" }

        server_version = packet.read_long
        debug { "server reports sftp version #{server_version}" }

        negotiated_version = [server_version, HIGHEST_PROTOCOL_VERSION_SUPPORTED].min
        info { "negotiated version is #{negotiated_version}" }

        extensions = {}
        until packet.eof?
          name = packet.read_string
          data = packet.read_string
          extensions[name] = data
        end

        @protocol = Protocol.load(self, negotiated_version)
        @pending_requests = {}

        @state = :open
        @on_ready.each { |callback| callback.call(self) }
        @on_ready = nil
      end

      # Parses the packet, finds the associated Request instance, and tells
      # the Request instance to respond to the packet (see Request#respond_to).
      def dispatch_request(packet)
        id = packet.read_long
        request = pending_requests.delete(id) or raise Net::SFTP::Exception, "no such request `#{id}'"
        request.respond_to(packet)
      end
  end

end; end