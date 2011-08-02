require 'net/ssh/loggable'

module Net; module SFTP; module Operations

  # A convenience class for working with remote directories. It provides methods
  # for searching and enumerating directory entries, similarly to the standard
  # ::Dir class.
  #
  #   sftp.dir.foreach("/remote/path") do |entry|
  #     puts entry.name
  #   end
  #
  #   p sftp.dir.entries("/remote/path").map { |e| e.name }
  #
  #   sftp.dir.glob("/remote/path", "**/*.rb") do |entry|
  #     puts entry.name
  #   end
  class Dir
    # The SFTP session object that drives this directory factory.
    attr_reader :sftp

    # Create a new instance on top of the given SFTP session instance.
    def initialize(sftp)
      @sftp = sftp
    end

    # Calls the block once for each entry in the named directory on the
    # remote server. Yields a Name object to the block, rather than merely
    # the name of the entry.
    def foreach(path)
      handle = sftp.opendir!(path)
      while entries = sftp.readdir!(handle)
        entries.each { |entry| yield entry }
      end
      return nil
    ensure
      sftp.close!(handle) if handle
    end

    # Returns an array of Name objects representing the items in the given
    # remote directory, +path+.
    def entries(path)
      results = []
      foreach(path) { |entry| results << entry }
      return results
    end

    # Works as ::Dir.glob, matching (possibly recursively) all directory
    # entries under +path+ against +pattern+. If a block is given, matches
    # will be yielded to the block as they are found; otherwise, they will
    # be returned in an array when the method finishes.
    #
    # Because working over an SFTP connection is always going to be slower than
    # working purely locally, don't expect this method to perform with the
    # same level of alacrity that ::Dir.glob does; it will work best for
    # shallow directory hierarchies with relatively few directories, though
    # it should be able to handle modest numbers of files in each directory.
    def glob(path, pattern, flags=0)
      flags |= ::File::FNM_PATHNAME
      path = path.chop if path[-1,1] == "/"

      results = [] unless block_given?
      queue = entries(path).reject { |e| e.name == "." || e.name == ".." }
      while queue.any?
        entry = queue.shift

        if entry.directory? && !%w(. ..).include?(::File.basename(entry.name))
          queue += entries("#{path}/#{entry.name}").map do |e|
            e.name.replace("#{entry.name}/#{e.name}")
            e
          end
        end

        if ::File.fnmatch(pattern, entry.name, flags)
          if block_given?
            yield entry
          else
            results << entry
          end
        end
      end

      return results unless block_given?
    end

    # Identical to calling #glob with a +flags+ parameter of 0 and no block.
    # Simply returns the matched entries as an array.
    def [](path, pattern)
      glob(path, pattern, 0)
    end
  end

end; end; end