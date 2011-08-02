require 'fog/core/model'

module Fog
  module AWS
    class Compute

      class Image < Fog::Model

        identity :id,                     :aliases => 'imageId'

        attribute :architecture
        attribute :block_device_mapping,  :aliases => 'blockDeviceMapping'
        attribute :location,              :aliases => 'imageLocation'
        attribute :owner_id,              :aliases => 'imageOwnerId'
        attribute :state,                 :aliases => 'imageState'
        attribute :type,                  :aliases => 'imageType'
        attribute :is_public,             :aliases => 'isPublic'
        attribute :kernel_id,             :aliases => 'kernelId'
        attribute :platform
        attribute :product_codes,         :aliases => 'productCodes'
        attribute :ramdisk_id,            :aliases => 'ramdiskId'
        attribute :root_device_type,      :aliases => 'rootDeviceType'
        attribute :root_device_name,      :aliases => 'rootDeviceName'
        attribute :tags,                  :aliases => 'tagSet'

        def deregister(delete_snapshot = false)
          connection.deregister_image(id)

          if(delete_snapshot && root_device_type == "ebs")
            block_device = block_device_mapping.select {|block_device| block_device['deviceName'] == root_device_name}
            @connection.snapshots.new(:id => block_device['snapshotId']).destroy
          else
            true
          end
        end

      end

    end
  end
end
