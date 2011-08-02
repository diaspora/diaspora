require 'fog/core/collection'
require 'fog/brightbox/models/compute/server'

module Fog
  module Brightbox
    class Compute

      class Servers < Fog::Collection

        model Fog::Brightbox::Compute::Server

        def all
          data = connection.list_servers
          load(data)
        end

        def get(identifier)
          return nil if identifier.nil? || identifier == ""
          data = connection.get_server(identifier)
          new(data)
        rescue Excon::Errors::NotFound
          nil
        end

      end

    end
  end
end