require 'net/sftp/protocol/01/attributes'

module Net; module SFTP; module Protocol; module V04

  # A class representing the attributes of a file or directory on the server.
  # It may be used to specify new attributes, or to query existing attributes.
  # This particular class is specific to versions 4 and 5 of the SFTP
  # protocol.
  #
  # To specify new attributes, just pass a hash as the argument to the
  # constructor. The following keys are supported:
  #
  # * :type:: the type of the item (integer, one of the T_ constants)
  # * :size:: the size of the item (integer)
  # * :uid:: the user-id that owns the file (integer)
  # * :gid:: the group-id that owns the file (integer)
  # * :owner:: the name of the user that owns the file (string)
  # * :group:: the name of the group that owns the file (string)
  # * :permissions:: the permissions on the file (integer, e.g. 0755)
  # * :atime:: the access time of the file (integer, seconds since epoch)
  # * :atime_nseconds:: the nanosecond component of atime (integer)
  # * :createtime:: the time at which the file was created (integer, seconds since epoch)
  # * :createtime_nseconds:: the nanosecond component of createtime (integer)
  # * :mtime:: the modification time of the file (integer, seconds since epoch)
  # * :mtime_nseconds:: the nanosecond component of mtime (integer)
  # * :acl:: an array of ACL entries for the item
  # * :extended:: a hash of name/value pairs identifying extended info
  #
  # Likewise, when the server sends an Attributes object, all of the
  # above attributes are exposed as methods (though not all will be set with
  # non-nil values from the server).
  class Attributes < V01::Attributes

    F_ACCESSTIME        = 0x00000008
    F_CREATETIME        = 0x00000010
    F_MODIFYTIME        = 0x00000020
    F_ACL               = 0x00000040
    F_OWNERGROUP        = 0x00000080
    F_SUBSECOND_TIMES   = 0x00000100
    
    # A simple struct for representing a single entry in an Access Control
    # List. (See Net::SFTP::Constants::ACE)
    ACL = Struct.new(:type, :flag, :mask, :who)

    class <<self
      # The list of supported elements in the attributes structure as defined
      # by v4 of the sftp protocol.
      def elements #:nodoc:
        @elements ||= [
          [:type,                :byte,    0],
          [:size,                :int64,   V01::Attributes::F_SIZE],
          [:owner,               :string,  F_OWNERGROUP],
          [:group,               :string,  F_OWNERGROUP],
          [:permissions,         :long,    V01::Attributes::F_PERMISSIONS],
          [:atime,               :int64,   F_ACCESSTIME],
          [:atime_nseconds,      :long,    F_ACCESSTIME | F_SUBSECOND_TIMES],
          [:createtime,          :int64,   F_CREATETIME],
          [:createtime_nseconds, :long,    F_CREATETIME | F_SUBSECOND_TIMES],
          [:mtime,               :int64,   F_MODIFYTIME],
          [:mtime_nseconds,      :long,    F_MODIFYTIME | F_SUBSECOND_TIMES],
          [:acl,                 :special, F_ACL],
          [:extended,            :special, V01::Attributes::F_EXTENDED]
        ]
      end

      private

        # A helper method for parsing the ACL entry in an Attributes struct.
        def parse_acl(buffer)
          acl_buf = Net::SSH::Buffer.new(buffer.read_string)
          acl = []
          acl_buf.read_long.times do
            acl << ACL.new(acl_buf.read_long, acl_buf.read_long, acl_buf.read_long, acl_buf.read_string)
          end
          acl
        end
    end

    # The type of the item on the remote server. Must be one of the T_* constants.
    attr_accessor :type

    # The owner of the item on the remote server, as a string.
    attr_writer   :owner

    # The group of the item on the remote server, as a string.
    attr_writer   :group

    # The nanosecond component of the access time.
    attr_accessor :atime_nseconds

    # The creation time of the remote item, in seconds since the epoch.
    attr_accessor :createtime

    # The nanosecond component of the creation time.
    attr_accessor :createtime_nseconds

    # The nanosecond component of the modification time.
    attr_accessor :mtime_nseconds

    # The array of access control entries for this item.
    attr_accessor :acl

    # Create a new Attributes instance with the given attributes. The
    # following keys are supported:
    #
    # * :type:: the type of the item (integer, one of the T_ constants)
    # * :size:: the size of the item (integer)
    # * :uid:: the user-id that owns the file (integer)
    # * :gid:: the group-id that owns the file (integer)
    # * :owner:: the name of the user that owns the file (string)
    # * :group:: the name of the group that owns the file (string)
    # * :permissions:: the permissions on the file (integer, e.g. 0755)
    # * :atime:: the access time of the file (integer, seconds since epoch)
    # * :atime_nseconds:: the nanosecond component of atime (integer)
    # * :createtime:: the time at which the file was created (integer, seconds since epoch)
    # * :createtime_nseconds:: the nanosecond component of createtime (integer)
    # * :mtime:: the modification time of the file (integer, seconds since epoch)
    # * :mtime_nseconds:: the nanosecond component of mtime (integer)
    # * :acl:: an array of ACL entries for the item
    # * :extended:: a hash of name/value pairs identifying extended info
    #
    # All of them default to +nil+ if omitted, except for +type+, which defaults
    # to T_REGULAR.
    def initialize(attributes={})
      super
      attributes[:type] ||= T_REGULAR
    end

    private

      # Perform protocol-version-specific preparations for serialization.
      def prepare_serialization!
        # force the group/owner to be translated from uid/gid, if those keys
        # were given on instantiation
        owner
        group
      end

      # Performs protocol-version-specific encoding of the access control
      # list, if one exists.
      def encode_acl(buffer)
        acl_buf = Net::SSH::Buffer.from(:long, acl.length)
        acl.each do |item|
          acl_buf.write_long item.type, item.flag, item.mask
          acl_buf.write_string item.who
        end
        buffer.write_string(acl_buf.to_s)
      end

  end

end ; end ; end ; end
