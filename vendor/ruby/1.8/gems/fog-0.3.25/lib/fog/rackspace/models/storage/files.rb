require 'fog/core/collection'
require 'fog/rackspace/models/storage/file'

module Fog
  module Rackspace
    class Storage

      class Files < Fog::Collection

        attribute :directory
        attribute :limit
        attribute :marker
        attribute :path
        attribute :prefix

        model Fog::Rackspace::Storage::File

        def all(options = {})
          requires :directory
          options = {
            'limit'   => limit,
            'marker'  => marker,
            'path'    => path,
            'prefix'  => prefix
          }.merge!(options)
          merge_attributes(options)
          parent = directory.collection.get(
            directory.key,
            options
          )
          if parent
            load(parent.files.map {|file| file.attributes})
          else
            nil
          end
        end

        def get(key, &block)
          requires :directory
          data = connection.get_object(directory.key, key, &block)
          file_data = data.headers.merge({
            :body => data.body,
            :key  => key
          })
          new(file_data)
        rescue Fog::Rackspace::Storage::NotFound
          nil
        end

        def get_url(key, expires)
          requires :directory
          connection.get_object_url(directory.key, key, expires)
        end

        def head(key, options = {})
          requires :directory
          data = connection.head_object(directory.key, key)
          file_data = data.headers.merge({
            :key => key
          })
          new(file_data)
        rescue Fog::Rackspace::Storage::NotFound
          nil
        end

        def new(attributes = {})
          requires :directory
          super({ :directory => directory }.merge!(attributes))
        end

      end

    end
  end
end
