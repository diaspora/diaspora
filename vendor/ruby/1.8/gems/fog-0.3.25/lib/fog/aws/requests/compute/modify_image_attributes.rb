module Fog
  module AWS
    class Compute
      class Real

        # Modify image attributes
        #
        # ==== Parameters
        # * image_id<~String> - Id of machine image to modify
        # * attribute<~String> - Attribute to modify, in ['launchPermission', 'productCodes']
        # * operation_type<~String> - Operation to perform on attribute, in ['add', 'remove']
        #
        def modify_image_attributes(image_id, attribute, operation_type, options = {})
          params = {}
          params.merge!(AWS.indexed_param('UserId', options['UserId']))
          params.merge!(AWS.indexed_param('UserGroup', options['UserGroup']))
          params.merge!(AWS.indexed_param('ProductCode', options['ProductCode']))
          request({
            'Action'        => 'ModifyImageAttribute',
            'Attribute'     => attribute,
            'ImageId'       => image_id,
            'OperationType' => operation_type,
            :idempotent     => true,
            :parser         => Fog::Parsers::AWS::Compute::Basic.new
          }.merge!(params))
        end

      end

      class Mock

        def modify_image_attributes(image_id, attribute, operation_type, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
