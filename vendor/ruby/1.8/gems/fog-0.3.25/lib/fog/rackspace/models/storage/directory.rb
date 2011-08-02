require 'fog/core/model'
require 'fog/rackspace/models/storage/files'

module Fog
  module Rackspace
    class Storage

      class Directory < Fog::Model
        extend Fog::Deprecation
        deprecate(:name, :key)
        deprecate(:name=, :key=)

        identity  :key, :aliases => 'name'

        attribute :bytes, :aliases => 'X-Container-Bytes-Used'
        attribute :count, :aliases => 'X-Container-Object-Count'

        def destroy
          requires :key
          connection.delete_container(key)
          true
        rescue Excon::Errors::NotFound
          false
        end

        def files
          @files ||= begin
            Fog::Rackspace::Storage::Files.new(
              :directory    => self,
              :connection   => connection
            )
          end
        end

        def public=(new_public)
          @public = new_public
        end

        def public_url
          requires :key
          @public_url ||= begin
            begin response = connection.cdn.head_container(key)
              response.headers['X-CDN-Enabled'] == 'True' && response.headers['X-CDN-URI']
            rescue Fog::Service::NotFound
              nil
            end
          end
        end

        def save
          requires :key
          connection.put_container(key)
          if @public
            @public_url = connection.cdn.put_container(key, 'X-CDN-Enabled' => 'True').headers['X-CDN-URI']
          else
            connection.cdn.put_container(key, 'X-CDN-Enabled' => 'False')
            @public_url = nil
          end
          true
        end

      end

    end
  end
end
