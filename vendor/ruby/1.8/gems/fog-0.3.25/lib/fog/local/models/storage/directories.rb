require 'fog/core/collection'
require 'fog/local/models/storage/directory'

module Fog
  module Local
    class Storage

      class Directories < Fog::Collection

        model Fog::Local::Storage::Directory

        def all
          data = Dir.entries(connection.local_root).select do |entry|
            entry[0...1] != '.' && ::File.directory?(connection.path_to(entry))
          end.map do |entry|
            {:key => entry}
          end
          load(data)
        end

        def get(key)
          if ::File.directory?(connection.path_to(key))
            new(:key => key)
          else
            nil
          end
        end

      end

    end
  end
end
