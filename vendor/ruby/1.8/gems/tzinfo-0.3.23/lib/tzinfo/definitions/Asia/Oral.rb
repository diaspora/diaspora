module TZInfo
  module Definitions
    module Asia
      module Oral
        include TimezoneDefinition
        
        timezone 'Asia/Oral' do |tz|
          tz.offset :o0, 12324, 0, :LMT
          tz.offset :o1, 14400, 0, :URAT
          tz.offset :o2, 18000, 0, :URAT
          tz.offset :o3, 18000, 3600, :URAST
          tz.offset :o4, 21600, 0, :URAT
          tz.offset :o5, 14400, 3600, :URAST
          tz.offset :o6, 14400, 0, :ORAT
          tz.offset :o7, 14400, 3600, :ORAST
          tz.offset :o8, 18000, 0, :ORAT
          
          tz.transition 1924, 5, :o1, 17452132973, 7200
          tz.transition 1930, 6, :o2, 7278445, 3
          tz.transition 1981, 3, :o3, 354913200
          tz.transition 1981, 9, :o4, 370720800
          tz.transition 1982, 3, :o3, 386445600
          tz.transition 1982, 9, :o2, 402256800
          tz.transition 1983, 3, :o3, 417985200
          tz.transition 1983, 9, :o2, 433792800
          tz.transition 1984, 3, :o3, 449607600
          tz.transition 1984, 9, :o2, 465339600
          tz.transition 1985, 3, :o3, 481064400
          tz.transition 1985, 9, :o2, 496789200
          tz.transition 1986, 3, :o3, 512514000
          tz.transition 1986, 9, :o2, 528238800
          tz.transition 1987, 3, :o3, 543963600
          tz.transition 1987, 9, :o2, 559688400
          tz.transition 1988, 3, :o3, 575413200
          tz.transition 1988, 9, :o2, 591138000
          tz.transition 1989, 3, :o5, 606862800
          tz.transition 1989, 9, :o1, 622591200
          tz.transition 1990, 3, :o5, 638316000
          tz.transition 1990, 9, :o1, 654645600
          tz.transition 1991, 12, :o6, 692827200
          tz.transition 1992, 3, :o7, 701809200
          tz.transition 1992, 9, :o6, 717530400
          tz.transition 1993, 3, :o7, 733269600
          tz.transition 1993, 9, :o6, 748994400
          tz.transition 1994, 3, :o7, 764719200
          tz.transition 1994, 9, :o6, 780444000
          tz.transition 1995, 3, :o7, 796168800
          tz.transition 1995, 9, :o6, 811893600
          tz.transition 1996, 3, :o7, 828223200
          tz.transition 1996, 10, :o6, 846367200
          tz.transition 1997, 3, :o7, 859672800
          tz.transition 1997, 10, :o6, 877816800
          tz.transition 1998, 3, :o7, 891122400
          tz.transition 1998, 10, :o6, 909266400
          tz.transition 1999, 3, :o7, 922572000
          tz.transition 1999, 10, :o6, 941320800
          tz.transition 2000, 3, :o7, 954021600
          tz.transition 2000, 10, :o6, 972770400
          tz.transition 2001, 3, :o7, 985471200
          tz.transition 2001, 10, :o6, 1004220000
          tz.transition 2002, 3, :o7, 1017525600
          tz.transition 2002, 10, :o6, 1035669600
          tz.transition 2003, 3, :o7, 1048975200
          tz.transition 2003, 10, :o6, 1067119200
          tz.transition 2004, 3, :o7, 1080424800
          tz.transition 2004, 10, :o6, 1099173600
          tz.transition 2005, 3, :o8, 1110830400
        end
      end
    end
  end
end
