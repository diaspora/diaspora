module Fog
  module AWS
    class SimpleDB
      class Real

        require 'fog/aws/parsers/simpledb/get_attributes'

        # List metadata for SimpleDB domain
        #
        # ==== Parameters
        # * domain_name<~String> - Name of domain. Must be between 3 and 255 of the
        #   following characters: a-z, A-Z, 0-9, '_', '-' and '.'.
        # * item_name<~String> - Name of the item.  May use any UTF-8 characters valid
        #   in xml.  Control characters and sequences not allowed in xml are not
        #   valid.  Can be up to 1024 bytes long.
        # * attributes<~Array> - Attributes to return from the item.  Defaults to
        #   {}, which will return all attributes. Attribute names and values may use
        #   any UTF-8 characters valid in xml. Control characters and sequences not 
        #   allowed in xml are not valid.  Each name and value can be up to 1024
        #   bytes long.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'Attributes' - list of attribute name/values for the item
        #     * 'BoxUsage'
        #     * 'RequestId'
        def get_attributes(domain_name, item_name, attributes = {})
          
          request({
            'Action'      => 'GetAttributes',
            'DomainName'  => domain_name,
            'ItemName'    => item_name,
            :parser       => Fog::Parsers::AWS::SimpleDB::GetAttributes.new(@nil_string)
          }.merge!(encode_attribute_names(attributes)))
        end

      end

      class Mock

        def get_attributes(domain_name, item_name, attributes = nil)
          response = Excon::Response.new
          if @data[:domains][domain_name]
            object = {}
            if attributes
              for attribute in attributes
                if @data[:domains][domain_name][item_name] && @data[:domains][domain_name][item_name]
                  object[attribute] = @data[:domains][domain_name][item_name][attribute]
                end
              end
            elsif @data[:domains][domain_name][item_name]
              object = @data[:domains][domain_name][item_name]
            end
            response.status = 200
            response.body = {
              'Attributes'  => object,
              'BoxUsage'    => Fog::AWS::Mock.box_usage,
              'RequestId'   => Fog::AWS::Mock.request_id
            }
          else
            response.status = 400
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
          response
        end

      end
    end
  end
end
