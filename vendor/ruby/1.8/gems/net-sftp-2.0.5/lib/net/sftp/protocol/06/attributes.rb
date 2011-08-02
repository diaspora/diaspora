require 'net/sftp/protocol/04/attributes'

module Net; module SFTP; module Protocol; module V06

  # A class representing the attributes of a file or directory on the server.
  # It may be used to specify new attributes, or to query existing attributes.
  # This particular class is specific to versions 6 and higher of the SFTP
  # protocol.
  #
  # To specify new attributes, just pass a hash as the argument to the
  # constructor. The following keys are supported:
  #
  # * :type:: the type of the item (integer, one of the T_ constants)
  # * :size:: the size of the item (integer)
  # * :allocation_size:: the actual number of bytes that the item uses on disk (integer)
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
  # * :ctime:: the time that the file's attributes were last changed (integer)
  # * :ctime_nseconds:: the nanosecond component of ctime (integer)
  # * :acl:: an array of ACL entries for the item
  # * :attrib_bits:: other attributes of the file or directory (as a bit field) (integer)
  # * :attrib_bits_valid:: a mask describing which bits in attrib_bits are valid (integer)
  # * :text_hint:: whether the file may or may not contain textual data (integer)
  # * :mime_type:: the mime type of the file (string)
  # * :link_count:: the hard link count of the file (integer)
  # * :untranslated_name:: the value of the filename before filename translation was attempted (string)
  # * :extended:: a hash of name/value pairs identifying extended info
  #
  # Likewise, when the server sends an Attributes object, all of the
  # above attributes are exposed as methods (though not all will be set with
  # non-nil values from the server).
  class Attributes < V04::Attributes
    F_BITS              = 0x00000200
    F_ALLOCATION_SIZE   = 0x00000400
    F_TEXT_HINT         = 0x00000800
    F_MIME_TYPE         = 0x00001000
    F_LINK_COUNT        = 0x00002000
    F_UNTRANSLATED_NAME = 0x00004000
    F_CTIME             = 0x00008000

    # The array of elements that describe this structure, in order. Used when
    # parsing and serializing attribute objects.
    def self.elements #:nodoc:
      @elements ||= [
        [:type,                :byte,    0],
        [:size,                :int64,   F_SIZE],
        [:allocation_size,     :int64,   F_ALLOCATION_SIZE],
        [:owner,               :string,  F_OWNERGROUP],
        [:group,               :string,  F_OWNERGROUP],
        [:permissions,         :long,    F_PERMISSIONS],
        [:atime,               :int64,   F_ACCESSTIME],
        [:atime_nseconds,      :long,    F_ACCESSTIME | F_SUBSECOND_TIMES],
        [:createtime,          :int64,   F_CREATETIME],
        [:createtime_nseconds, :long,    F_CREATETIME | F_SUBSECOND_TIMES],
        [:mtime,               :int64,   F_MODIFYTIME],
        [:mtime_nseconds,      :long,    F_MODIFYTIME | F_SUBSECOND_TIMES],
        [:ctime,               :int64,   F_CTIME],
        [:ctime_nseconds,      :long,    F_CTIME | F_SUBSECOND_TIMES],
        [:acl,                 :special, F_ACL],
        [:attrib_bits,         :long,    F_BITS],
        [:attrib_bits_valid,   :long,    F_BITS],
        [:text_hint,           :byte,    F_TEXT_HINT],
        [:mime_type,           :string,  F_MIME_TYPE],
        [:link_count,          :long,    F_LINK_COUNT],
        [:untranslated_name,   :string,  F_UNTRANSLATED_NAME],
        [:extended,            :special, F_EXTENDED]
      ]
    end

    # The size on-disk of the file
    attr_accessor :allocation_size

    # The time at which the file's attributes were last changed
    attr_accessor :ctime

    # The nanosecond component of #ctime
    attr_accessor :ctime_nseconds

    # Other attributes of this file or directory (as a bit field)
    attr_accessor :attrib_bits

    # A bit mask describing which bits in #attrib_bits are valid
    attr_accessor :attrib_bits_valid

    # Describes whether the file may or may not contain textual data
    attr_accessor :text_hint

    # The mime-type of the file
    attr_accessor :mime_type

    # The hard link count for the file
    attr_accessor :link_count

    # The value of the file name before filename translation was attempted
    attr_accessor :untranslated_name
  end

end; end; end; end