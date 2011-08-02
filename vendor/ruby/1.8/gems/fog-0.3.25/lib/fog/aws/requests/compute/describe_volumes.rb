module Fog
  module AWS
    class Compute
      class Real

        require 'fog/aws/parsers/compute/describe_volumes'

        # Describe all or specified volumes.
        #
        # ==== Parameters
        # * filters<~Hash> - List of filters to limit results with
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'volumeSet'<~Array>:
        #       * 'availabilityZone'<~String> - Availability zone for volume
        #       * 'createTime'<~Time> - Timestamp for creation
        #       * 'size'<~Integer> - Size in GiBs for volume
        #       * 'snapshotId'<~String> - Snapshot volume was created from, if any
        #       * 'status'<~String> - State of volume
        #       * 'volumeId'<~String> - Reference to volume
        #       * 'attachmentSet'<~Array>:
        #         * 'attachmentTime'<~Time> - Timestamp for attachment
        #         * 'deleteOnTermination'<~Boolean> - Whether or not to delete volume on instance termination
        #         * 'device'<~String> - How value is exposed to instance
        #         * 'instanceId'<~String> - Reference to attached instance
        #         * 'status'<~String> - Attachment state
        #         * 'volumeId'<~String> - Reference to volume
        def describe_volumes(filters = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_volumes with #{filters.class} param is deprecated, use describe_volumes('volume-id' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'volume-id' => [*filters]}
          end
          params = AWS.indexed_filters(filters)
          request({
            'Action'    => 'DescribeVolumes',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::DescribeVolumes.new
          }.merge!(params))
        end

      end

      class Mock

        def describe_volumes(filters = {})
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] describe_volumes with #{filters.class} param is deprecated, use describe_volumes('volume-id' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'volume-id' => [*filters]}
          end

          if filters.keys.any? {|key| key =~ /^tag/}
            Formatador.display_line("[yellow][WARN] describe_volumes tag filters are not yet mocked[/] [light_black](#{caller.first})[/]")
            Fog::Mock.not_implemented
          end

          response = Excon::Response.new

          volume_set = @data[:volumes].values

          aliases = {
            'availability-zone' => 'availabilityZone',
            'create-time' => 'createTime',
            'size' => 'size',
            'snapshot-id' => 'snapshotId',
            'status' => 'status',
            'volume-id' => 'volumeId'
          }
          attachment_aliases = {
            'attach-time' => 'attachTime',
            'delete-on-termination' => 'deleteOnTermination',
            'device'      => 'device',
            'instance-id' => 'instanceId',
            'status'      => 'status'
          }
          for filter_key, filter_value in filters
            if attachment_key = filter_key.split('attachment.')[1]
              aliased_key = permission_aliases[filter_key]
              volume_set = volume_set.reject{|volume| !volume['attachmentSet'].detect {|attachment| [*filter_value].include?(attachment[aliased_key])}}
            else
              aliased_key = aliases[filter_key]
              volume_set = volume_set.reject{|volume| ![*filter_value].include?(volume[aliased_key])}
            end
          end

          volume_set.each do |volume|
            case volume['status']
            when 'attaching'
              if Time.now - volume['attachmentSet'].first['attachTime'] > Fog::Mock.delay
                volume['attachmentSet'].first['status'] = 'in-use'
                volume['status'] = 'in-use'
              end
            when 'creating'
              if Time.now - volume['createTime'] > Fog::Mock.delay
                volume['status'] = 'available'
              end
            when 'deleting'
              if Time.now - @data[:deleted_at][volume['volumeId']] > Fog::Mock.delay
                @data[:deleted_at].delete(volume['volumeId'])
                @data[:volumes].delete(volume['volumeId'])
              end
            end
          end
          volume_set = volume_set.reject {|volume| !@data[:volumes][volume['volumeId']]}

          response.status = 200
          response.body = {
            'requestId' => Fog::AWS::Mock.request_id,
            'volumeSet' => volume_set
          }
          response
        end

      end
    end
  end
end
