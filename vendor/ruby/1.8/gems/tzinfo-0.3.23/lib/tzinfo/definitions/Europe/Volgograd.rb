module TZInfo
  module Definitions
    module Europe
      module Volgograd
        include TimezoneDefinition
        
        timezone 'Europe/Volgograd' do |tz|
          tz.offset :o0, 10660, 0, :LMT
          tz.offset :o1, 10800, 0, :TSAT
          tz.offset :o2, 10800, 0, :STAT
          tz.offset :o3, 14400, 0, :STAT
          tz.offset :o4, 14400, 0, :VOLT
          tz.offset :o5, 14400, 3600, :VOLST
          tz.offset :o6, 10800, 3600, :VOLST
          tz.offset :o7, 10800, 0, :VOLT
          
          tz.transition 1920, 1, :o1, 10464449947, 4320
          tz.transition 1925, 4, :o2, 19393971, 8
          tz.transition 1930, 6, :o3, 19409187, 8
          tz.transition 1961, 11, :o4, 7312843, 3
          tz.transition 1981, 3, :o5, 354916800
          tz.transition 1981, 9, :o4, 370724400
          tz.transition 1982, 3, :o5, 386452800
          tz.transition 1982, 9, :o4, 402260400
          tz.transition 1983, 3, :o5, 417988800
          tz.transition 1983, 9, :o4, 433796400
          tz.transition 1984, 3, :o5, 449611200
          tz.transition 1984, 9, :o4, 465343200
          tz.transition 1985, 3, :o5, 481068000
          tz.transition 1985, 9, :o4, 496792800
          tz.transition 1986, 3, :o5, 512517600
          tz.transition 1986, 9, :o4, 528242400
          tz.transition 1987, 3, :o5, 543967200
          tz.transition 1987, 9, :o4, 559692000
          tz.transition 1988, 3, :o5, 575416800
          tz.transition 1988, 9, :o4, 591141600
          tz.transition 1989, 3, :o6, 606866400
          tz.transition 1989, 9, :o7, 622594800
          tz.transition 1990, 3, :o6, 638319600
          tz.transition 1990, 9, :o7, 654649200
          tz.transition 1991, 3, :o4, 670374000
          tz.transition 1992, 3, :o6, 701820000
          tz.transition 1992, 9, :o7, 717534000
          tz.transition 1993, 3, :o6, 733273200
          tz.transition 1993, 9, :o7, 748998000
          tz.transition 1994, 3, :o6, 764722800
          tz.transition 1994, 9, :o7, 780447600
          tz.transition 1995, 3, :o6, 796172400
          tz.transition 1995, 9, :o7, 811897200
          tz.transition 1996, 3, :o6, 828226800
          tz.transition 1996, 10, :o7, 846370800
          tz.transition 1997, 3, :o6, 859676400
          tz.transition 1997, 10, :o7, 877820400
          tz.transition 1998, 3, :o6, 891126000
          tz.transition 1998, 10, :o7, 909270000
          tz.transition 1999, 3, :o6, 922575600
          tz.transition 1999, 10, :o7, 941324400
          tz.transition 2000, 3, :o6, 954025200
          tz.transition 2000, 10, :o7, 972774000
          tz.transition 2001, 3, :o6, 985474800
          tz.transition 2001, 10, :o7, 1004223600
          tz.transition 2002, 3, :o6, 1017529200
          tz.transition 2002, 10, :o7, 1035673200
          tz.transition 2003, 3, :o6, 1048978800
          tz.transition 2003, 10, :o7, 1067122800
          tz.transition 2004, 3, :o6, 1080428400
          tz.transition 2004, 10, :o7, 1099177200
          tz.transition 2005, 3, :o6, 1111878000
          tz.transition 2005, 10, :o7, 1130626800
          tz.transition 2006, 3, :o6, 1143327600
          tz.transition 2006, 10, :o7, 1162076400
          tz.transition 2007, 3, :o6, 1174777200
          tz.transition 2007, 10, :o7, 1193526000
          tz.transition 2008, 3, :o6, 1206831600
          tz.transition 2008, 10, :o7, 1224975600
          tz.transition 2009, 3, :o6, 1238281200
          tz.transition 2009, 10, :o7, 1256425200
          tz.transition 2010, 3, :o6, 1269730800
          tz.transition 2010, 10, :o7, 1288479600
          tz.transition 2011, 3, :o6, 1301180400
          tz.transition 2011, 10, :o7, 1319929200
          tz.transition 2012, 3, :o6, 1332630000
          tz.transition 2012, 10, :o7, 1351378800
          tz.transition 2013, 3, :o6, 1364684400
          tz.transition 2013, 10, :o7, 1382828400
          tz.transition 2014, 3, :o6, 1396134000
          tz.transition 2014, 10, :o7, 1414278000
          tz.transition 2015, 3, :o6, 1427583600
          tz.transition 2015, 10, :o7, 1445727600
          tz.transition 2016, 3, :o6, 1459033200
          tz.transition 2016, 10, :o7, 1477782000
          tz.transition 2017, 3, :o6, 1490482800
          tz.transition 2017, 10, :o7, 1509231600
          tz.transition 2018, 3, :o6, 1521932400
          tz.transition 2018, 10, :o7, 1540681200
          tz.transition 2019, 3, :o6, 1553986800
          tz.transition 2019, 10, :o7, 1572130800
          tz.transition 2020, 3, :o6, 1585436400
          tz.transition 2020, 10, :o7, 1603580400
          tz.transition 2021, 3, :o6, 1616886000
          tz.transition 2021, 10, :o7, 1635634800
          tz.transition 2022, 3, :o6, 1648335600
          tz.transition 2022, 10, :o7, 1667084400
          tz.transition 2023, 3, :o6, 1679785200
          tz.transition 2023, 10, :o7, 1698534000
          tz.transition 2024, 3, :o6, 1711839600
          tz.transition 2024, 10, :o7, 1729983600
          tz.transition 2025, 3, :o6, 1743289200
          tz.transition 2025, 10, :o7, 1761433200
          tz.transition 2026, 3, :o6, 1774738800
          tz.transition 2026, 10, :o7, 1792882800
          tz.transition 2027, 3, :o6, 1806188400
          tz.transition 2027, 10, :o7, 1824937200
          tz.transition 2028, 3, :o6, 1837638000
          tz.transition 2028, 10, :o7, 1856386800
          tz.transition 2029, 3, :o6, 1869087600
          tz.transition 2029, 10, :o7, 1887836400
          tz.transition 2030, 3, :o6, 1901142000
          tz.transition 2030, 10, :o7, 1919286000
          tz.transition 2031, 3, :o6, 1932591600
          tz.transition 2031, 10, :o7, 1950735600
          tz.transition 2032, 3, :o6, 1964041200
          tz.transition 2032, 10, :o7, 1982790000
          tz.transition 2033, 3, :o6, 1995490800
          tz.transition 2033, 10, :o7, 2014239600
          tz.transition 2034, 3, :o6, 2026940400
          tz.transition 2034, 10, :o7, 2045689200
          tz.transition 2035, 3, :o6, 2058390000
          tz.transition 2035, 10, :o7, 2077138800
          tz.transition 2036, 3, :o6, 2090444400
          tz.transition 2036, 10, :o7, 2108588400
          tz.transition 2037, 3, :o6, 2121894000
          tz.transition 2037, 10, :o7, 2140038000
          tz.transition 2038, 3, :o6, 59172251, 24
          tz.transition 2038, 10, :o7, 59177459, 24
          tz.transition 2039, 3, :o6, 59180987, 24
          tz.transition 2039, 10, :o7, 59186195, 24
          tz.transition 2040, 3, :o6, 59189723, 24
          tz.transition 2040, 10, :o7, 59194931, 24
          tz.transition 2041, 3, :o6, 59198627, 24
          tz.transition 2041, 10, :o7, 59203667, 24
          tz.transition 2042, 3, :o6, 59207363, 24
          tz.transition 2042, 10, :o7, 59212403, 24
          tz.transition 2043, 3, :o6, 59216099, 24
          tz.transition 2043, 10, :o7, 59221139, 24
          tz.transition 2044, 3, :o6, 59224835, 24
          tz.transition 2044, 10, :o7, 59230043, 24
          tz.transition 2045, 3, :o6, 59233571, 24
          tz.transition 2045, 10, :o7, 59238779, 24
          tz.transition 2046, 3, :o6, 59242307, 24
          tz.transition 2046, 10, :o7, 59247515, 24
          tz.transition 2047, 3, :o6, 59251211, 24
          tz.transition 2047, 10, :o7, 59256251, 24
          tz.transition 2048, 3, :o6, 59259947, 24
          tz.transition 2048, 10, :o7, 59264987, 24
          tz.transition 2049, 3, :o6, 59268683, 24
          tz.transition 2049, 10, :o7, 59273891, 24
          tz.transition 2050, 3, :o6, 59277419, 24
          tz.transition 2050, 10, :o7, 59282627, 24
        end
      end
    end
  end
end
