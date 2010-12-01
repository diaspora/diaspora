module TZInfo
  module Definitions
    module Europe
      module Samara
        include TimezoneDefinition
        
        timezone 'Europe/Samara' do |tz|
          tz.offset :o0, 12036, 0, :LMT
          tz.offset :o1, 10800, 0, :SAMT
          tz.offset :o2, 14400, 0, :SAMT
          tz.offset :o3, 14400, 0, :KUYT
          tz.offset :o4, 14400, 3600, :KUYST
          tz.offset :o5, 10800, 3600, :KUYST
          tz.offset :o6, 10800, 0, :KUYT
          tz.offset :o7, 7200, 3600, :KUYST
          tz.offset :o8, 14400, 3600, :SAMST
          tz.offset :o9, 10800, 3600, :SAMST
          
          tz.transition 1919, 6, :o1, 17439411197, 7200
          tz.transition 1930, 6, :o2, 19409187, 8
          tz.transition 1935, 1, :o3, 7283488, 3
          tz.transition 1981, 3, :o4, 354916800
          tz.transition 1981, 9, :o3, 370724400
          tz.transition 1982, 3, :o4, 386452800
          tz.transition 1982, 9, :o3, 402260400
          tz.transition 1983, 3, :o4, 417988800
          tz.transition 1983, 9, :o3, 433796400
          tz.transition 1984, 3, :o4, 449611200
          tz.transition 1984, 9, :o3, 465343200
          tz.transition 1985, 3, :o4, 481068000
          tz.transition 1985, 9, :o3, 496792800
          tz.transition 1986, 3, :o4, 512517600
          tz.transition 1986, 9, :o3, 528242400
          tz.transition 1987, 3, :o4, 543967200
          tz.transition 1987, 9, :o3, 559692000
          tz.transition 1988, 3, :o4, 575416800
          tz.transition 1988, 9, :o3, 591141600
          tz.transition 1989, 3, :o5, 606866400
          tz.transition 1989, 9, :o6, 622594800
          tz.transition 1990, 3, :o5, 638319600
          tz.transition 1990, 9, :o6, 654649200
          tz.transition 1991, 3, :o7, 670374000
          tz.transition 1991, 9, :o6, 686102400
          tz.transition 1991, 10, :o2, 687916800
          tz.transition 1992, 3, :o8, 701809200
          tz.transition 1992, 9, :o2, 717530400
          tz.transition 1993, 3, :o8, 733269600
          tz.transition 1993, 9, :o2, 748994400
          tz.transition 1994, 3, :o8, 764719200
          tz.transition 1994, 9, :o2, 780444000
          tz.transition 1995, 3, :o8, 796168800
          tz.transition 1995, 9, :o2, 811893600
          tz.transition 1996, 3, :o8, 828223200
          tz.transition 1996, 10, :o2, 846367200
          tz.transition 1997, 3, :o8, 859672800
          tz.transition 1997, 10, :o2, 877816800
          tz.transition 1998, 3, :o8, 891122400
          tz.transition 1998, 10, :o2, 909266400
          tz.transition 1999, 3, :o8, 922572000
          tz.transition 1999, 10, :o2, 941320800
          tz.transition 2000, 3, :o8, 954021600
          tz.transition 2000, 10, :o2, 972770400
          tz.transition 2001, 3, :o8, 985471200
          tz.transition 2001, 10, :o2, 1004220000
          tz.transition 2002, 3, :o8, 1017525600
          tz.transition 2002, 10, :o2, 1035669600
          tz.transition 2003, 3, :o8, 1048975200
          tz.transition 2003, 10, :o2, 1067119200
          tz.transition 2004, 3, :o8, 1080424800
          tz.transition 2004, 10, :o2, 1099173600
          tz.transition 2005, 3, :o8, 1111874400
          tz.transition 2005, 10, :o2, 1130623200
          tz.transition 2006, 3, :o8, 1143324000
          tz.transition 2006, 10, :o2, 1162072800
          tz.transition 2007, 3, :o8, 1174773600
          tz.transition 2007, 10, :o2, 1193522400
          tz.transition 2008, 3, :o8, 1206828000
          tz.transition 2008, 10, :o2, 1224972000
          tz.transition 2009, 3, :o8, 1238277600
          tz.transition 2009, 10, :o2, 1256421600
          tz.transition 2010, 3, :o9, 1269727200
          tz.transition 2010, 10, :o1, 1288479600
          tz.transition 2011, 3, :o9, 1301180400
          tz.transition 2011, 10, :o1, 1319929200
          tz.transition 2012, 3, :o9, 1332630000
          tz.transition 2012, 10, :o1, 1351378800
          tz.transition 2013, 3, :o9, 1364684400
          tz.transition 2013, 10, :o1, 1382828400
          tz.transition 2014, 3, :o9, 1396134000
          tz.transition 2014, 10, :o1, 1414278000
          tz.transition 2015, 3, :o9, 1427583600
          tz.transition 2015, 10, :o1, 1445727600
          tz.transition 2016, 3, :o9, 1459033200
          tz.transition 2016, 10, :o1, 1477782000
          tz.transition 2017, 3, :o9, 1490482800
          tz.transition 2017, 10, :o1, 1509231600
          tz.transition 2018, 3, :o9, 1521932400
          tz.transition 2018, 10, :o1, 1540681200
          tz.transition 2019, 3, :o9, 1553986800
          tz.transition 2019, 10, :o1, 1572130800
          tz.transition 2020, 3, :o9, 1585436400
          tz.transition 2020, 10, :o1, 1603580400
          tz.transition 2021, 3, :o9, 1616886000
          tz.transition 2021, 10, :o1, 1635634800
          tz.transition 2022, 3, :o9, 1648335600
          tz.transition 2022, 10, :o1, 1667084400
          tz.transition 2023, 3, :o9, 1679785200
          tz.transition 2023, 10, :o1, 1698534000
          tz.transition 2024, 3, :o9, 1711839600
          tz.transition 2024, 10, :o1, 1729983600
          tz.transition 2025, 3, :o9, 1743289200
          tz.transition 2025, 10, :o1, 1761433200
          tz.transition 2026, 3, :o9, 1774738800
          tz.transition 2026, 10, :o1, 1792882800
          tz.transition 2027, 3, :o9, 1806188400
          tz.transition 2027, 10, :o1, 1824937200
          tz.transition 2028, 3, :o9, 1837638000
          tz.transition 2028, 10, :o1, 1856386800
          tz.transition 2029, 3, :o9, 1869087600
          tz.transition 2029, 10, :o1, 1887836400
          tz.transition 2030, 3, :o9, 1901142000
          tz.transition 2030, 10, :o1, 1919286000
          tz.transition 2031, 3, :o9, 1932591600
          tz.transition 2031, 10, :o1, 1950735600
          tz.transition 2032, 3, :o9, 1964041200
          tz.transition 2032, 10, :o1, 1982790000
          tz.transition 2033, 3, :o9, 1995490800
          tz.transition 2033, 10, :o1, 2014239600
          tz.transition 2034, 3, :o9, 2026940400
          tz.transition 2034, 10, :o1, 2045689200
          tz.transition 2035, 3, :o9, 2058390000
          tz.transition 2035, 10, :o1, 2077138800
          tz.transition 2036, 3, :o9, 2090444400
          tz.transition 2036, 10, :o1, 2108588400
          tz.transition 2037, 3, :o9, 2121894000
          tz.transition 2037, 10, :o1, 2140038000
          tz.transition 2038, 3, :o9, 59172251, 24
          tz.transition 2038, 10, :o1, 59177459, 24
          tz.transition 2039, 3, :o9, 59180987, 24
          tz.transition 2039, 10, :o1, 59186195, 24
          tz.transition 2040, 3, :o9, 59189723, 24
          tz.transition 2040, 10, :o1, 59194931, 24
          tz.transition 2041, 3, :o9, 59198627, 24
          tz.transition 2041, 10, :o1, 59203667, 24
          tz.transition 2042, 3, :o9, 59207363, 24
          tz.transition 2042, 10, :o1, 59212403, 24
          tz.transition 2043, 3, :o9, 59216099, 24
          tz.transition 2043, 10, :o1, 59221139, 24
          tz.transition 2044, 3, :o9, 59224835, 24
          tz.transition 2044, 10, :o1, 59230043, 24
          tz.transition 2045, 3, :o9, 59233571, 24
          tz.transition 2045, 10, :o1, 59238779, 24
          tz.transition 2046, 3, :o9, 59242307, 24
          tz.transition 2046, 10, :o1, 59247515, 24
          tz.transition 2047, 3, :o9, 59251211, 24
          tz.transition 2047, 10, :o1, 59256251, 24
          tz.transition 2048, 3, :o9, 59259947, 24
          tz.transition 2048, 10, :o1, 59264987, 24
          tz.transition 2049, 3, :o9, 59268683, 24
          tz.transition 2049, 10, :o1, 59273891, 24
          tz.transition 2050, 3, :o9, 59277419, 24
          tz.transition 2050, 10, :o1, 59282627, 24
        end
      end
    end
  end
end
