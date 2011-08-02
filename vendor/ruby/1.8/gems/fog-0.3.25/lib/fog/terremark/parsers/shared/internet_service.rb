module Fog
  module Parsers
    module Terremark
      module Shared

        class InternetService < Fog::Parsers::Base

          def reset
            @in_public_ip_address = false
            @response = { 'PublicIpAddress' => {} }
          end

          def start_element(name, attributes)
            super
            case name
            when 'Href'
              data = {}
              until attributes.empty?
                data[attributes.shift] = attributes.shift
              end
              if @in_public_ip_address
                @response['PublicIpAddress'][name] = data
              else
                @response[name] = data
              end
            when 'PublicIpAddress'
              @in_public_ip_address = true
            end
          end

          def end_element(name)
            case name
            when 'Description', 'Protocol'
              @response[name] = @value
            when 'Enabled'
              if @value == 'false'
                @response[name] = false
              else
                @response[name] = true
              end
            when 'Id'
              if @in_public_ip_address
                @response['PublicIpAddress'][name] = @value.to_i
              else
                @response[name] = @value.to_i
              end
            when 'Name'
              if @in_public_ip_address
                @response['PublicIpAddress'][name] = @value
              else
                @response[name] = @value
              end
            when 'Port', 'Timeout'
              @response[name] = @value.to_i
            when 'PublicIpAddress'
              @in_public_ip_address = false
            end
          end

        end

      end
    end
  end
end
