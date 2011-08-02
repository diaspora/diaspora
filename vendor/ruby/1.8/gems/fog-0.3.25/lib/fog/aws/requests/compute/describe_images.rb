module Fog
  module AWS
    class Compute
      class Real

        require 'fog/aws/parsers/compute/describe_images'

        # Describe all or specified images.
        #
        # ==== Params
        # * filters<~Hash> - List of filters to limit results with
        #   * filters and/or the following
        #   * 'ExecutableBy'<~String> - Only return images that the executable_by
        #     user has explicit permission to launch
        #   * 'ImageId'<~Array> - Ids of images to describe
        #   * 'Owner'<~String> - Only return images belonging to owner.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'imagesSet'<~Array>:
        #       * 'architecture'<~String> - Architecture of the image
        #       * 'blockDeviceMapping'<~Array> - An array of mapped block devices
        #       * 'imageId'<~String> - Id of the image
        #       * 'imageLocation'<~String> - Location of the image
        #       * 'imageOwnerId'<~String> - Id of the owner of the image
        #       * 'imageState'<~String> - State of the image
        #       * 'imageType'<~String> - Type of the image
        #       * 'isPublic'<~Boolean> - Whether or not the image is public
        #       * 'kernelId'<~String> - Kernel id associated with image, if any
        #       * 'platform'<~String> - Operating platform of the image
        #       * 'productCodes'<~Array> - Product codes for the image
        #       * 'ramdiskId'<~String> - Ramdisk id associated with image, if any
        #       * 'rootDeviceName'<~String> - Root device name, e.g. /dev/sda1
        #       * 'rootDeviceType'<~String> - Root device type, ebs or instance-store
        def describe_images(filters = {})
          options = {}
          for key in ['ExecutableBy', 'ImageId', 'Owner']
            if filters.is_a?(Hash) && filters.key?(key)
              options[key] = filters.delete(key)
            end
          end
          params = AWS.indexed_filters(filters).merge!(options)
          request({
            'Action'    => 'DescribeImages',
            :idempotent => true,
            :parser     => Fog::Parsers::AWS::Compute::DescribeImages.new
          }.merge!(params))
        end

      end

      class Mock

        def describe_images(filters = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
