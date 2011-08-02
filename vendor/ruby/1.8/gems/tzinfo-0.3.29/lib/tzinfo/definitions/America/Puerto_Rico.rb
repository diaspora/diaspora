module TZInfo
  module Definitions
    module America
      module Puerto_Rico
        include TimezoneDefinition
        
        timezone 'America/Puerto_Rico' do |tz|
          tz.offset :o0, -15865, 0, :LMT
          tz.offset :o1, -14400, 0, :AST
          tz.offset :o2, -14400, 3600, :AWT
          tz.offset :o3, -14400, 3600, :APT
          
          tz.transition 1899, 3, :o1, 41726744933, 17280
          tz.transition 1942, 5, :o2, 7291448, 3
          tz.transition 1945, 8, :o3, 58360379, 24
          tz.transition 1945, 9, :o1, 58361489, 24
        end
      end
    end
  end
end
