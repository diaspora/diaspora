require 'fog/core/collection'
require 'fog/aws/models/compute/snapshot'

module Fog
  module AWS
    class Compute

      class Snapshots < Fog::Collection

        attribute :filters
        attribute :volume

        model Fog::AWS::Compute::Snapshot

        def initialize(attributes)
          self.filters ||= { 'RestorableBy' => 'self' }
          super
        end

        def all(filters = filters, options = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] all with #{filters.class} param is deprecated, use all('snapshot-id' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'snapshot-id' => [*filters]}
          end
          self.filters = filters
          data = connection.describe_snapshots(filters.merge!(options)).body
          load(data['snapshotSet'])
          if volume
            self.replace(self.select {|snapshot| snapshot.volume_id == volume.id})
          end
          self
        end

        def get(snapshot_id)
          if snapshot_id
            self.class.new(:connection => connection).all('snapshot-id' => snapshot_id).first
          end
        end

        def new(attributes = {})
          if volume
            super({ 'volumeId' => volume.id }.merge!(attributes))
          else
            super
          end
        end

      end

    end
  end
end
