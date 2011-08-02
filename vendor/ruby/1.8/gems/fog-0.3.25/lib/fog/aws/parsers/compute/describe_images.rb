module Fog
  module Parsers
    module AWS
      module Compute

        class DescribeImages < Fog::Parsers::Base

          def reset
            @block_device_mapping = {}
            @image = { 'blockDeviceMapping' => [], 'productCodes' => [], 'tagSet' => {} }
            @response = { 'imagesSet' => [] }
            @tag = {}
          end

          def start_element(name, attrs = [])
            super
            case name
            when 'productCodes'
              @in_product_codes = true
            when 'blockDeviceMapping'
              @in_block_device_mapping = true
            when 'tagSet'
              @in_tag_set = true
            end
          end

          def end_element(name)
            case name
            when 'architecture',  'imageId', 'imageLocation', 'imageOwnerId', 'imageState', 'imageType', 'kernelId', 'platform', 'ramdiskId', 'rootDeviceType','rootDeviceName'
              @image[name] = @value
            when 'blockDeviceMapping'
              @in_block_device_mapping = false
            when 'deviceName', 'virtualName', 'snapshotId', 'deleteOnTermination'
              @block_device_mapping[name] = @value
            when 'isPublic'
              if @value == 'true'
                @image[name] = true
              else
                @image[name] = false
              end
            when 'item'
              if @in_block_device_mapping
                @image['blockDeviceMapping'] << @block_device_mapping
                @block_device_mapping = {}
              elsif @in_tag_set
                @image['tagSet'][@tag['key']] = @tag['value']
                @tag = {}
              elsif !@in_product_codes
                @response['imagesSet'] << @image
                @image = { 'blockDeviceMapping' => [], 'productCodes' => [], 'tagSet' => {} }
              end
            when 'key', 'value'
              @tag[name] = @value
            when 'productCode'
              @image['productCodes'] << @value
            when 'productCodes'
              @in_product_codes = false
            when 'requestId'
              @response[name] = @value
            when 'volumeSize'
              @block_device_mapping[name] = @value.to_i
            end
          end

        end

      end
    end
  end
end
