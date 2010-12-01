module TZInfo
  module Definitions
    module Antarctica
      module Casey
        include TimezoneDefinition
        
        timezone 'Antarctica/Casey' do |tz|
          tz.offset :o0, 0, 0, :zzz
          tz.offset :o1, 28800, 0, :WST
          tz.offset :o2, 39600, 0, :CAST
          
          tz.transition 1969, 1, :o1, 4880445, 2
          tz.transition 2009, 10, :o2, 1255802400
          tz.transition 2010, 3, :o1, 1267714800
        end
      end
    end
  end
end
