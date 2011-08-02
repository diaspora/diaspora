module Fog
  module Terremark
    module Shared
      module Parser

        remove_method :parse
        def parse(data)
          case data['type']
          when 'application/vnd.vmware.vcloud.vApp+xml'
            servers.new(data.merge!(:connection => self))
          else
            data
          end
        end

      end
    end
  end
end
