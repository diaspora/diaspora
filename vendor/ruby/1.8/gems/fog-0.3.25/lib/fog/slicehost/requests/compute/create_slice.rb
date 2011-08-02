module Fog
  module Slicehost
    class Compute
      class Real

        require 'fog/slicehost/parsers/compute/create_slice'

        # Get list of slices
        # ==== Parameters
        # * flavor_id<~Integer> - Id of flavor to create slice with
        # * image_id<~Integer> - Id of image to create slice with
        # * name<~String> - Name of slice
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        #     * 'addresses'<~Array> - Ip addresses for the slice
        #     * 'backup-id'<~Integer> - Id of backup slice was booted from
        #     * 'bw-in'<~Integer> - Incoming bandwidth total for current billing cycle, in Gigabytes
        #     * 'bw-out'<~Integer> - Outgoing bandwidth total for current billing cycle, in Gigabytes
        #     * 'flavor-id'<~Integer> - Id of flavor slice was booted from
        #     * 'id'<~Integer> - Id of the slice
        #     * 'image-id'<~Integer> - Id of image slice was booted from
        #     * 'name'<~String> - Name of the slice
        #     * 'progress'<~Integer> - Progress of current action, in percentage
        #     * 'root-password'<~String> - Root password of slice
        #     * 'status'<~String> - Current status of the slice
        def create_slice(flavor_id, image_id, name)
          request(
            :body     => %Q{<?xml version="1.0" encoding="UTF-8"?><slice><flavor-id type="integer">#{flavor_id}</flavor-id><image-id type="integer">#{image_id}</image-id><name>#{name}</name></slice>},
            :expects  => 201,
            :method   => 'POST',
            :parser   => Fog::Parsers::Slicehost::Compute::CreateSlice.new,
            :path     => 'slices.xml'
          )
        end

      end

      class Mock

        def create_slice(flavor_id, image_id, name)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
