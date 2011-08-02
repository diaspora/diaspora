module Net; module SFTP; module Protocol; module V01

  # Represents a single named item on the remote server. This includes the
  # name, attributes about the item, and the "longname", which is intended
  # for use when displaying directory data, and has no specified format.
  class Name
    # The name of the item on the remote server.
    attr_reader :name

    # The display-ready name of the item, possibly with other attributes.
    attr_reader :longname

    # The Attributes object describing this item.
    attr_reader :attributes

    # Create a new Name object with the given name, longname, and attributes.
    def initialize(name, longname, attributes)
      @name, @longname, @attributes = name, longname, attributes
    end

    # Returns +true+ if the item appears to be a directory. It does this by
    # examining the attributes. If there is insufficient information in the
    # attributes, this will return nil, rather than a boolean.
    def directory?
      attributes.directory?
    end

    # Returns +true+ if the item appears to be a symlink. It does this by
    # examining the attributes. If there is insufficient information in the
    # attributes, this will return nil, rather than a boolean.
    def symlink?
      attributes.symlink?
    end

    # Returns +true+ if the item appears to be a regular file. It does this by
    # examining the attributes. If there is insufficient information in the
    # attributes, this will return nil, rather than a boolean.
    def file?
      attributes.file?
    end
  end

end; end; end; end