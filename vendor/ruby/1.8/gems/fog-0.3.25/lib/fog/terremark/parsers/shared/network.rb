module Fog
  module Parsers
    module Terremark
      module Shared

        class Network < Fog::Parsers::Base

          def reset
            @response = {
              "links" => []
            }
          end

          def start_element(name,attributes=[])
            super
            case name
            when "Network"
              until attributes.empty?
                val = attributes.shift
                if val.is_a?(String)
                  @response[val] = attributes.shift
                end
              end
              if @response.has_key?("name")
                @response["subnet"] = @response["name"]
              end
              if @response.has_key?("href")
                @response["id"] = @response["href"].split("/").last
              end
            when "Link"
              link = {}
              until attributes.empty?
                link[attributes.shift] = attributes.shift
              end
              @response["links"] << link
            end
          end

          def end_element(name)
            case name
            when "Gateway", "Netmask", "FenceMode"
              @response[name.downcase] = @value
            end
          end

        end

      end
    end
  end
end
