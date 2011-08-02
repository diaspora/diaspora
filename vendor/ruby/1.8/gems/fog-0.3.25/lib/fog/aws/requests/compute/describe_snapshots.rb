module Fog
  module AWS
    class Compute
      class Real

        require 'fog/aws/parsers/compute/describe_snapshots'

        # Describe all or specified snapshots
        #
        # ==== Parameters
        # * filters<~Hash> - List of filters to limit results with
        # * options<~Hash>:
        #   * 'Owner'<~String> - Owner of snapshot in ['self', 'amazon', account_id]
        #   * 'RestorableBy'<~String> - Account id of user who can create volumes from this snapshot
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'snapshotSet'<~Array>:
        #       * 'progress'<~String>: The percentage progress of the snapshot
        #       * 'snapshotId'<~String>: Id of the snapshot
        #       * 'startTime'<~Time>: Timestamp of when snapshot was initiated
        #       * 'status'<~String>: Snapshot state, in ['pending', 'completed']
        #       * 'volumeId'<~String>: Id of volume that snapshot contains
        def describe_snapshots(filters = {}, options = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_snapshots with #{filters.class} param is deprecated, use describe_snapshots('snapshot-id' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'snapshot-id' => [*filters]}
          end
          unless options.empty?
            Formatador.display_line("[yellow][WARN] describe_snapshots with a second param is deprecated, use describe_snapshots(options) instead[/] [light_black](#{caller.first})[/]")
          end

          for key in ['ExecutableBy', 'ImageId', 'Owner', 'RestorableBy']
            if filters.has_key?(key)
              options[key] = filters.delete(key)
            end
          end
          options['RestorableBy'] ||= 'self'
          params = AWS.indexed_filters(filters).merge!(options)
          request({
            'Action'    => 'DescribeSnapshots',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::DescribeSnapshots.new
          }.merge!(params))
        end

      end

      class Mock

        def describe_snapshots(filters = {}, options = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_snapshots with #{filters.class} param is deprecated, use describe_snapshots('snapshot-id' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'snapshot-id' => [*filters]}
          end
          unless options.empty?
            Formatador.display_line("[yellow][WARN] describe_snapshots with a second param is deprecated, use describe_snapshots(options) instead[/] [light_black](#{caller.first})[/]")
          end

          if filters.keys.any? {|key| key =~ /^tag/}
            Formatador.display_line("[yellow][WARN] describe_snapshots tag filters are not yet mocked[/] [light_black](#{caller.first})[/]")
            Fog::Mock.not_implemented
          end

          response = Excon::Response.new

          snapshot_set = @data[:snapshots].values

          if filters.delete('owner-alias')
            Formatador.display_line("[yellow][WARN] describe_snapshots with owner-alias is not mocked[/] [light_black](#{caller.first})[/]")
          end
          if filters.delete('RestorableBy')
            Formatador.display_line("[yellow][WARN] describe_snapshots with RestorableBy is not mocked[/] [light_black](#{caller.first})[/]")
          end

          aliases = {
            'description' => 'description',
            'owner-id'    => 'ownerId',
            'progress'    => 'progress',
            'snapshot-id' => 'snapshotId',
            'start-time'  => 'startTime',
            'status'      => 'status',
            'volume-id'   => 'volumeId',
            'volume-size' => 'volumeSize'
          }
          for filter_key, filter_value in filters
            aliased_key = aliases[filter_key]
            snapshot_set = snapshot_set.reject{|snapshot| ![*filter_value].include?(snapshot[aliased_key])}
          end

          snapshot_set.each do |snapshot|
            case snapshot['status']
            when 'in progress', 'pending'
              if Time.now - snapshot['startTime'] > Fog::Mock.delay * 2
                snapshot['progress']  = '100%'
                snapshot['status']    = 'completed'
              elsif Time.now - snapshot['startTime'] > Fog::Mock.delay
                snapshot['progress']  = '50%'
                snapshot['status']    = 'in progress'
              else
                snapshot['progress']  = '0%'
                snapshot['status']    = 'in progress'
              end
            end
          end

          response.status = 200
          response.body = {
            'requestId' => Fog::AWS::Mock.request_id,
            'snapshotSet' => snapshot_set
          }
          response
        end

      end
    end
  end
end
