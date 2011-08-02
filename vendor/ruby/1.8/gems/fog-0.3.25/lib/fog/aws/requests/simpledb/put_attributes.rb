module Fog
  module AWS
    class SimpleDB
      class Real

        # Put item attributes into a SimpleDB domain
        #
        # ==== Parameters
        # * domain_name<~String> - Name of domain. Must be between 3 and 255 of the
        # following characters: a-z, A-Z, 0-9, '_', '-' and '.'.
        # * item_name<~String> - Name of the item.  May use any UTF-8 characters valid
        #   in xml.  Control characters and sequences not allowed in xml are not
        #   valid.  Can be up to 1024 bytes long.
        # * attributes<~Hash> - Name/value pairs to add to the item.  Attribute names
        #   and values may use any UTF-8 characters valid in xml. Control characters
        #   and sequences not allowed in xml are not valid.  Each name and value can
        #   be up to 1024 bytes long.
        # * options<~Hash> - Accepts the following keys.
        #   :replace => [Array of keys to replace]
        #   :expect => {name/value pairs for performing conditional put}
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'BoxUsage'
        #     * 'RequestId'
        def put_attributes(domain_name, item_name, attributes, options = {})
          options[:expect] = {} unless options[:expect]
          options[:replace] = [] unless options[:replace]
          request({
            'Action'      => 'PutAttributes',
            'DomainName'  => domain_name,
            :parser       => Fog::Parsers::AWS::SimpleDB::Basic.new(@nil_string),
            'ItemName' => item_name
          }.merge!(encode_attributes(attributes, options[:replace], options[:expect])))
        end

      end

      class Mock

        def put_attributes(domain_name, item_name, attributes, options = {})
          options[:expect] = {} unless options[:expect]
          options[:replace] = [] unless options[:replace]
          response = Excon::Response.new
          if @data[:domains][domain_name]
            options[:expect].each do |ck, cv|
              if @data[:domains][domain_name][item_name][ck] != [cv]
                response.status = 409
                raise(Excon::Errors.status_error({:expects => 200}, response))
              end
            end
            attributes.each do |key, value|
              @data[:domains][domain_name][item_name] ||= {}
              @data[:domains][domain_name][item_name][key.to_s] = [] unless @data[:domains][domain_name][item_name][key.to_s]
              if options[:replace].include?(key.to_s)
                @data[:domains][domain_name][item_name][key.to_s] = [*value].map {|x| x.to_s}
              else
                @data[:domains][domain_name][item_name][key.to_s] += [*value].map {|x| x.to_s}
              end
            end
            response.status = 200
            response.body = {
              'BoxUsage'  => Fog::AWS::Mock.box_usage,
              'RequestId' => Fog::AWS::Mock.request_id
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
