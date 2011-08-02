module Fog
  module AWS
    class Compute
      class Real

        # Modify snapshot attributes
        #
        # ==== Parameters
        # * snapshot_id<~String> - Id of snapshot to modify
        # * attribute<~String> - Attribute to modify, in ['createVolumePermission']
        # * operation_type<~String> - Operation to perform on attribute, in ['add', 'remove']
        #
        def modify_snapshot_attribute(snapshot_id, attribute, operation_type, options = {})
          params = {}
          params.merge!(AWS.indexed_param('UserId', options['UserId']))
          params.merge!(AWS.indexed_param('UserGroup', options['UserGroup']))
          request({
            'Action'        => 'ModifySnapshotAttribute',
            'Attribute'     => attribute,
            'SnapshotId'    => snapshot_id,
            'OperationType' => operation_type,
            :idempotent     => true,
            :parser         => Fog::Parsers::AWS::Compute::Basic.new
          }.merge!(params))
        end

      end

      class Mock

        def modify_snapshot_attribute(snapshot_id, attribute, operation_type, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
