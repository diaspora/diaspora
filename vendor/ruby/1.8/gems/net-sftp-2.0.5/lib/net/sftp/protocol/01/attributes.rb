require 'net/ssh/buffer'

module Net; module SFTP; module Protocol; module V01

  # A class representing the attributes of a file or directory on the server.
  # It may be used to specify new attributes, or to query existing attributes.
  #
  # To specify new attributes, just pass a hash as the argument to the
  # constructor. The following keys are supported:
  #
  # * :size:: the size of the file
  # * :uid:: the user-id that owns the file (integer)
  # * :gid:: the group-id that owns the file (integer)
  # * :owner:: the name of the user that owns the file (string)
  # * :group:: the name of the group that owns the file (string)
  # * :permissions:: the permissions on the file (integer, e.g. 0755)
  # * :atime:: the access time of the file (integer, seconds since epoch)
  # * :mtime:: the modification time of the file (integer, seconds since epoch)
  # * :extended:: a hash of name/value pairs identifying extended info
  #
  # Likewise, when the server sends an Attributes object, all of the
  # above attributes are exposed as methods (though not all will be set with
  # non-nil values from the server).
  class Attributes

    F_SIZE        = 0x00000001
    F_UIDGID      = 0x00000002
    F_PERMISSIONS = 0x00000004
    F_ACMODTIME   = 0x00000008
    F_EXTENDED    = 0x80000000

    T_REGULAR      = 1
    T_DIRECTORY    = 2
    T_SYMLINK      = 3
    T_SPECIAL      = 4
    T_UNKNOWN      = 5
    T_SOCKET       = 6
    T_CHAR_DEVICE  = 7
    T_BLOCK_DEVICE = 8
    T_FIFO         = 9

    class <<self
      # Returns the array of attribute meta-data that defines the structure of
      # the attributes packet as described by this version of the protocol.
      def elements #:nodoc:
        @elements ||= [
          [:size,                :int64,   F_SIZE],
          [:uid,                 :long,    F_UIDGID],
          [:gid,                 :long,    F_UIDGID],
          [:permissions,         :long,    F_PERMISSIONS],
          [:atime,               :long,    F_ACMODTIME],
          [:mtime,               :long,    F_ACMODTIME],
          [:extended,            :special, F_EXTENDED]
        ]
      end

      # Parses the given buffer and returns an Attributes object compsed from
      # the data extracted from it.
      def from_buffer(buffer)
        flags = buffer.read_long
        data = {}

        elements.each do |name, type, condition|
          if flags & condition == condition
            if type == :special
              data[name] = send("parse_#{name}", buffer)
            else
              data[name] = buffer.send("read_#{type}")
            end
          end
        end

        new(data)
      end

      # A convenience method for defining methods that expose specific
      # attributes. This redefines the standard attr_accessor (an admittedly
      # bad practice) because (1) I don't need any "regular" accessors, and
      # (2) because rdoc will automatically pick up and note methods defined
      # via attr_accessor.
      def attr_accessor(name) #:nodoc:
        class_eval <<-CODE
          def #{name}
            attributes[:#{name}]
          end
        CODE

        attr_writer(name)
      end

      # A convenience method for defining methods that expose specific
      # attributes. This redefines the standard attr_writer (an admittedly
      # bad practice) because (1) I don't need any "regular" accessors, and
      # (2) because rdoc will automatically pick up and note methods defined
      # via attr_writer.
      def attr_writer(name) #:nodoc:
        class_eval <<-CODE
          def #{name}=(value)
            attributes[:#{name}] = value
          end
        CODE
      end

      private

        # Parse the hash of extended data from the buffer.
        def parse_extended(buffer)
          extended = Hash.new
          buffer.read_long.times do
            extended[buffer.read_string] = buffer.read_string
          end
          extended
        end
    end

    # The hash of name/value pairs that backs this Attributes instance
    attr_reader   :attributes

    # The size of the file.
    attr_accessor :size

    # The user-id of the user that owns the file
    attr_writer   :uid

    # The group-id of the user that owns the file
    attr_writer   :gid

    # The permissions on the file
    attr_accessor :permissions

    # The last access time of the file
    attr_accessor :atime

    # The modification time of the file
    attr_accessor :mtime

    # The hash of name/value pairs identifying extended information about the file
    attr_accessor :extended

    # Create a new Attributes instance with the given attributes. The
    # following keys are supported:
    #
    # * :size:: the size of the file
    # * :uid:: the user-id that owns the file (integer)
    # * :gid:: the group-id that owns the file (integer)
    # * :owner:: the name of the user that owns the file (string)
    # * :group:: the name of the group that owns the file (string)
    # * :permissions:: the permissions on the file (integer, e.g. 0755)
    # * :atime:: the access time of the file (integer, seconds since epoch)
    # * :mtime:: the modification time of the file (integer, seconds since epoch)
    # * :extended:: a hash of name/value pairs identifying extended info
    def initialize(attributes={})
      @attributes = attributes
    end

    # Returns the user-id of the user that owns the file, or +nil+ if that
    # information is not available. If an :owner key exists, but not a :uid
    # key, the Etc module will be used to reverse lookup the id from the name.
    # This might fail on some systems (e.g., Windows).
    def uid
      if attributes[:owner] && !attributes.key?(:uid)
        require 'etc'
        attributes[:uid] = Etc.getpwnam(attributes[:owner]).uid
      end
      attributes[:uid]
    end

    # Returns the group-id of the group that owns the file, or +nil+ if that
    # information is not available. If a :group key exists, but not a :gid
    # key, the Etc module will be used to reverse lookup the id from the name.
    # This might fail on some systems (e.g., Windows).
    def gid
      if attributes[:group] && !attributes.key?(:gid)
        require 'etc'
        attributes[:gid] = Etc.getgrnam(attributes[:group]).gid
      end
      attributes[:gid]
    end

    # Returns the username of the user that owns the file, or +nil+ if that
    # information is not available. If the :uid is given, but not the :owner,
    # the Etc module will be used to lookup the name from the id. This might
    # fail on some systems (e.g. Windows).
    def owner
      if attributes[:uid] && !attributes[:owner]
        require 'etc'
        attributes[:owner] = Etc.getpwuid(attributes[:uid].to_i).name
      end
      attributes[:owner]
    end

    # Returns the group name of the group that owns the file, or +nil+ if that
    # information is not available. If the :gid is given, but not the :group,
    # the Etc module will be used to lookup the name from the id. This might
    # fail on some systems (e.g. Windows).
    def group
      if attributes[:gid] && !attributes[:group]
        require 'etc'
        attributes[:group] = Etc.getgrgid(attributes[:gid].to_i).name
      end
      attributes[:group]
    end

    # Inspects the permissions bits to determine what type of entity this
    # attributes object represents. If will return one of the T_ constants.
    def type
      if    permissions & 0140000 == 0140000 then 
        T_SOCKET
      elsif permissions & 0120000 == 0120000 then 
        T_SYMLINK
      elsif permissions & 0100000 == 0100000 then
        T_REGULAR
      elsif permissions &  060000 ==  060000 then
        T_BLOCK_DEVICE
      elsif permissions &  040000 ==  040000 then
        T_DIRECTORY
      elsif permissions &  020000 ==  020000 then
        T_CHAR_DEVICE
      elsif permissions &  010000 ==  010000 then
        T_FIFO
      else
        T_UNKNOWN
      end
    end

    # Returns the type as a symbol, rather than an integer, for easier use in
    # Ruby programs.
    def symbolic_type
      case type
      when T_SOCKET       then :socket
      when T_SYMLINK      then :symlink
      when T_REGULAR      then :regular
      when T_BLOCK_DEVICE then :block_device
      when T_DIRECTORY    then :directory
      when T_CHAR_DEVICE  then :char_device
      when T_FIFO         then :fifo
      when T_SPECIAL      then :special
      when T_UNKNOWN      then :unknown
      else raise NotImplementedError, "unknown file type #{type} (bug?)"
      end
    end

    # Returns true if these attributes appear to describe a directory.
    def directory?
      case type
      when T_DIRECTORY then true
      when T_UNKNOWN   then nil
      else false
      end
    end

    # Returns true if these attributes appear to describe a symlink.
    def symlink?
      case type
      when T_SYMLINK then true
      when T_UNKNOWN then nil
      else false
      end
    end

    # Returns true if these attributes appear to describe a regular file.
    def file?
      case type
      when T_REGULAR then true
      when T_UNKNOWN then nil
      else false
      end
    end

    # Convert the object to a string suitable for passing in an SFTP
    # packet. This is the raw representation of the attribute packet payload,
    # and is not intended to be human readable.
    def to_s
      prepare_serialization!

      flags = 0

      self.class.elements.each do |name, type, condition|
        flags |= condition if attributes[name]
      end

      buffer = Net::SSH::Buffer.from(:long, flags)
      self.class.elements.each do |name, type, condition|
        if flags & condition == condition
          if type == :special
            send("encode_#{name}", buffer)
          else
            buffer.send("write_#{type}", attributes[name])
          end
        end
      end

      buffer.to_s
    end

    private

      # Perform protocol-version-specific preparations for serialization.
      def prepare_serialization!
        # force the uid/gid to be translated from owner/group, if those keys
        # were given on instantiation
        uid
        gid
      end

      # Encodes information about the extended info onto the end of the given
      # buffer.
      def encode_extended(buffer)
        buffer.write_long extended.size
        extended.each { |k,v| buffer.write_string k, v }
      end

  end

end ; end ; end ; end
