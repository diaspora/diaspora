module TZInfo
  module Definitions
    module America
      module Barbados
        include TimezoneDefinition
        
        timezone 'America/Barbados' do |tz|
          tz.offset :o0, -14308, 0, :LMT
          tz.offset :o1, -14308, 0, :BMT
          tz.offset :o2, -14400, 0, :AST
          tz.offset :o3, -14400, 3600, :ADT
          
          tz.transition 1924, 1, :o1, 52353770377, 21600
          tz.transition 1932, 1, :o2, 52416885577, 21600
          tz.transition 1977, 6, :o3, 234943200
          tz.transition 1977, 10, :o2, 244616400
          tz.transition 1978, 4, :o3, 261554400
          tz.transition 1978, 10, :o2, 276066000
          tz.transition 1979, 4, :o3, 293004000
          tz.transition 1979, 9, :o2, 307515600
          tz.transition 1980, 4, :o3, 325058400
          tz.transition 1980, 9, :o2, 338706000
        end
      end
    end
  end
end
