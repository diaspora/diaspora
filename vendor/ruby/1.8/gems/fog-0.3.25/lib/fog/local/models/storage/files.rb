require 'fog/core/collection'
require 'fog/local/models/storage/file'

module Fog
  module Local
    class Storage

      class Files < Fog::Collection

        attribute :directory

        model Fog::Local::Storage::File

        def all
          requires :directory
          if directory.collection.get(directory.key)
            data = Dir.entries(connection.path_to(directory.key)).select do |key|
              key[0...1] != '.' && !::File.directory?(connection.path_to(key))
            end.map do |key|
              path = file_path(key)
              {
                :content_length => ::File.size(path),
                :key            => CGI.unescape(key),
                :last_modified  => ::File.mtime(path)
              }
            end
            load(data)
          else
            nil
          end
        end

        def get(key, &block)
          requires :directory
          path = file_path(CGI.escape(key))
          if ::File.exists?(path)
            data = {
              :content_length => ::File.size(path),
              :key            => key,
              :last_modified  => ::File.mtime(path)
            }
            if block_given?
              file = ::File.open(path)
              while (chunk = file.read(Excon::CHUNK_SIZE)) && yield(chunk); end
              file.close
              new(data)
            else
              body = ::File.read(path)
              new(data.merge!(:body => body))
            end
          else
            nil
          end
        end

        def head(key)
          requires :directory
          path = file_path(CGI.escape(key))
          if ::File.exists?(path)
            new({
              :content_length => ::File.size(path),
              :key            => key,
              :last_modified  => ::File.mtime(path)
            })
          else
            nil
          end
        end

        def new(attributes = {})
          requires :directory
          super({ :directory => directory }.merge!(attributes))
        end

        private

        def file_path(key)
          connection.path_to(::File.join(directory.key, key))
        end

      end
    end
  end
end
