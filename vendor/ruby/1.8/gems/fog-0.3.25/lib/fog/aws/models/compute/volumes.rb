require 'fog/core/collection'
require 'fog/aws/models/compute/volume'

module Fog
  module AWS
    class Compute

      class Volumes < Fog::Collection

        attribute :filters
        attribute :server

        model Fog::AWS::Compute::Volume

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters = filters)
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] all with #{filters.class} param is deprecated, use all('volume-id' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'volume-id' => [*filters]}
          end
          self.filters = filters
          data = connection.describe_volumes(filters).body
          load(data['volumeSet'])
          if server
            self.replace(self.select {|volume| volume.server_id == server.id})
          end
          self
        end

        def get(volume_id)
          if volume_id
            self.class.new(:connection => connection).all('volume-id' => volume_id).first
          end
        end

        def new(attributes = {})
          if server
            super({ :server => server }.merge!(attributes))
          else
            super
          end
        end

      end

    end
  end
end
