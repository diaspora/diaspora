module Net module SFTP

  # The packet types and other general constants used by the SFTP protocol.
  # See the specification for the SFTP protocol for a full discussion of their
  # meaning and usage.
  module Constants

    # The various packet types supported by SFTP protocol versions 1 through 6.
    # The FXP_EXTENDED and FXP_EXTENDED_REPLY packet types are not currently
    # understood by Net::SFTP.
    module PacketTypes
      FXP_INIT           = 1
      FXP_VERSION        = 2
                         
      FXP_OPEN           = 3
      FXP_CLOSE          = 4
      FXP_READ           = 5
      FXP_WRITE          = 6
      FXP_LSTAT          = 7
      FXP_FSTAT          = 8
      FXP_SETSTAT        = 9
      FXP_FSETSTAT       = 10
      FXP_OPENDIR        = 11
      FXP_READDIR        = 12
      FXP_REMOVE         = 13
      FXP_MKDIR          = 14
      FXP_RMDIR          = 15
      FXP_REALPATH       = 16
      FXP_STAT           = 17
      FXP_RENAME         = 18
      FXP_READLINK       = 19
      FXP_SYMLINK        = 20
      FXP_LINK           = 21
      FXP_BLOCK          = 22
      FXP_UNBLOCK        = 23
                         
      FXP_STATUS         = 101
      FXP_HANDLE         = 102
      FXP_DATA           = 103
      FXP_NAME           = 104
      FXP_ATTRS          = 105
                         
      FXP_EXTENDED       = 200
      FXP_EXTENDED_REPLY = 201
    end

    # Beginning in version 5 of the protocol, Net::SFTP::Session#rename accepts
    # an optional +flags+ argument that must be either 0 or a combination of
    # these constants.
    module RenameFlags
      OVERWRITE = 0x00000001
      ATOMIC    = 0x00000002
      NATIVE    = 0x00000004
    end

    # When an FXP_STATUS packet is received from the server, the +code+ will
    # be one of the following constants.
    module StatusCodes
      FX_OK                     = 0
      FX_EOF                    = 1
      FX_NO_SUCH_FILE           = 2
      FX_PERMISSION_DENIED      = 3
      FX_FAILURE                = 4
      FX_BAD_MESSAGE            = 5
      FX_NO_CONNECTION          = 6
      FX_CONNECTION_LOST        = 7
      FX_OP_UNSUPPORTED         = 8
      FX_INVALID_HANDLE         = 9
      FX_NO_SUCH_PATH           = 10
      FX_FILE_ALREADY_EXISTS    = 11
      FX_WRITE_PROTECT          = 12
      FX_NO_MEDIA               = 13
      FX_NO_SPACE_ON_FILESYSTEM = 14
      FX_QUOTA_EXCEEDED         = 15
      FX_UNKNOWN_PRINCIPLE      = 16
      FX_LOCK_CONFlICT          = 17
      FX_DIR_NOT_EMPTY          = 18
      FX_NOT_A_DIRECTORY        = 19
      FX_INVALID_FILENAME       = 20
      FX_LINK_LOOP              = 21
    end

    # The Net::SFTP::Session#open operation is one of the worst casualties of
    # the revisions between SFTP protocol versions. The flags change considerably
    # between version 1 and version 6. Net::SFTP tries to shield programmers
    # from the differences, so you'll almost never need to use these flags
    # directly, but if you ever need to specify some flag that isn't exposed
    # by the higher-level API, these are the ones that are available to you.
    module OpenFlags
      # These are the flags that are understood by versions 1-4 of the the
      # open operation.
      module FV1
        READ   = 0x00000001
        WRITE  = 0x00000002
        APPEND = 0x00000004
        CREAT  = 0x00000008
        TRUNC  = 0x00000010
        EXCL   = 0x00000020
      end

      # Version 5 of the open operation totally discarded the flags understood
      # by versions 1-4, and replaced them with these.
      module FV5
        CREATE_NEW         = 0x00000000
        CREATE_TRUNCATE    = 0x00000001
        OPEN_EXISTING      = 0x00000002
        OPEN_OR_CREATE     = 0x00000003
        TRUNCATE_EXISTING  = 0x00000004

        APPEND_DATA        = 0x00000008
        APPEND_DATA_ATOMIC = 0x00000010
        TEXT_MODE          = 0x00000020
        READ_LOCK          = 0x00000040
        WRITE_LOCK         = 0x00000080
        DELETE_LOCK        = 0x00000100
      end

      # Version 6 of the open operation added these flags, in addition to the
      # flags understood by version 5.
      module FV6
        ADVISORY_LOCK           = 0x00000200
        NOFOLLOW                = 0x00000400
        DELETE_ON_CLOSE         = 0x00000800
        ACCESS_AUDIT_ALARM_INFO = 0x00001000
        ACCESS_BACKUP           = 0x00002000
        BACKUP_STREAM           = 0x00004000
        OVERRIDE_OWNER          = 0x00008000
      end
    end

    # The Net::SFTP::Session#block operation, implemented in version 6 of
    # the protocol, understands these constants for the +mask+ parameter.
    module LockTypes
      READ     = OpenFlags::FV5::READ_LOCK
      WRITE    = OpenFlags::FV5::WRITE_LOCK
      DELETE   = OpenFlags::FV5::DELETE_LOCK
      ADVISORY = OpenFlags::FV6::ADVISORY_LOCK
    end

    module ACE
      # Access control entry types, used from version 4 of the protocol,
      # onward. See Net::SFTP::Protocol::V04::Attributes::ACL.
      module Type
        ACCESS_ALLOWED = 0x00000000
        ACCESS_DENIED  = 0x00000001
        SYSTEM_AUDIT   = 0x00000002
        SYSTEM_ALARM   = 0x00000003
      end

      # Access control entry flags, used from version 4 of the protocol,
      # onward. See Net::SFTP::Protocol::V04::Attributes::ACL.
      module Flag
        FILE_INHERIT         = 0x00000001
        DIRECTORY_INHERIT    = 0x00000002
        NO_PROPAGATE_INHERIT = 0x00000004
        INHERIT_ONLY         = 0x00000008
        SUCCESSFUL_ACCESS    = 0x00000010
        FAILED_ACCESS        = 0x00000020
        IDENTIFIER_GROUP     = 0x00000040
      end

      # Access control entry masks, used from version 4 of the protocol,
      # onward. See Net::SFTP::Protocol::V04::Attributes::ACL.
      module Mask
        READ_DATA         = 0x00000001
        LIST_DIRECTORY    = 0x00000001
        WRITE_DATA        = 0x00000002
        ADD_FILE          = 0x00000002
        APPEND_DATA       = 0x00000004
        ADD_SUBDIRECTORY  = 0x00000004
        READ_NAMED_ATTRS  = 0x00000008
        WRITE_NAMED_ATTRS = 0x00000010
        EXECUTE           = 0x00000020
        DELETE_CHILD      = 0x00000040
        READ_ATTRIBUTES   = 0x00000080
        WRITE_ATTRIBUTES  = 0x00000100
        DELETE            = 0x00010000
        READ_ACL          = 0x00020000
        WRITE_ACL         = 0x00040000
        WRITE_OWNER       = 0x00080000
        SYNCHRONIZE       = 0x00100000
      end
    end

  end

end end
