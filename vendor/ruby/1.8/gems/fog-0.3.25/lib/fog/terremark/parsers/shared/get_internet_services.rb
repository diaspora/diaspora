module Fog
  module Parsers
    module Terremark
      module Shared

        class GetInternetServices < Fog::Parsers::Base

          def reset
            @in_public_ip_address = false
            @internet_service = {}
            @response = { 'InternetServices' => [] }
          end

          def start_element(name, attributes)
            super
            case name
            when 'PublicIpAddress'
              @in_public_ip_address = true
            end
          end

          def end_element(name)
            case name
            when 'Description', 'Protocol'
              @internet_service[name] = @value
            when 'Enabled'
              if @value == 'true'
                @internet_service[name] = true
              else
                @internet_service[name] = false
              end
            when 'Href', 'Name'
              if @in_public_ip_address
                @internet_service['PublicIpAddress'] ||= {}
                @internet_service['PublicIpAddress'][name] = @value
              else
                @internet_service[name] = @value
              end
            when 'Id'
              if @in_public_ip_address
                @internet_service['PublicIpAddress'] ||= {}
                @internet_service['PublicIpAddress'][name] = @value.to_i
              else
                @internet_service[name] = @value.to_i
              end
            when 'InternetService'
              @response['InternetServices'] << @internet_service
              @internet_service = {}
            when 'Port', 'Timeout'
              @internet_service[name] = @value.to_i
            when 'PublicIpAddress'
              @in_public_ip_address = false
            end
          end
        end

      end
    end
  end
end
