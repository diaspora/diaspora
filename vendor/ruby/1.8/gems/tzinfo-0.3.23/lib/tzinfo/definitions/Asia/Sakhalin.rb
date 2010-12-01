module TZInfo
  module Definitions
    module Asia
      module Sakhalin
        include TimezoneDefinition
        
        timezone 'Asia/Sakhalin' do |tz|
          tz.offset :o0, 34248, 0, :LMT
          tz.offset :o1, 32400, 0, :CJT
          tz.offset :o2, 32400, 0, :JST
          tz.offset :o3, 39600, 0, :SAKT
          tz.offset :o4, 39600, 3600, :SAKST
          tz.offset :o5, 36000, 3600, :SAKST
          tz.offset :o6, 36000, 0, :SAKT
          
          tz.transition 1905, 8, :o1, 8701488373, 3600
          tz.transition 1937, 12, :o2, 19431193, 8
          tz.transition 1945, 8, :o3, 19453537, 8
          tz.transition 1981, 3, :o4, 354891600
          tz.transition 1981, 9, :o3, 370699200
          tz.transition 1982, 3, :o4, 386427600
          tz.transition 1982, 9, :o3, 402235200
          tz.transition 1983, 3, :o4, 417963600
          tz.transition 1983, 9, :o3, 433771200
          tz.transition 1984, 3, :o4, 449586000
          tz.transition 1984, 9, :o3, 465318000
          tz.transition 1985, 3, :o4, 481042800
          tz.transition 1985, 9, :o3, 496767600
          tz.transition 1986, 3, :o4, 512492400
          tz.transition 1986, 9, :o3, 528217200
          tz.transition 1987, 3, :o4, 543942000
          tz.transition 1987, 9, :o3, 559666800
          tz.transition 1988, 3, :o4, 575391600
          tz.transition 1988, 9, :o3, 591116400
          tz.transition 1989, 3, :o4, 606841200
          tz.transition 1989, 9, :o3, 622566000
          tz.transition 1990, 3, :o4, 638290800
          tz.transition 1990, 9, :o3, 654620400
          tz.transition 1991, 3, :o5, 670345200
          tz.transition 1991, 9, :o6, 686073600
          tz.transition 1992, 1, :o3, 695750400
          tz.transition 1992, 3, :o4, 701784000
          tz.transition 1992, 9, :o3, 717505200
          tz.transition 1993, 3, :o4, 733244400
          tz.transition 1993, 9, :o3, 748969200
          tz.transition 1994, 3, :o4, 764694000
          tz.transition 1994, 9, :o3, 780418800
          tz.transition 1995, 3, :o4, 796143600
          tz.transition 1995, 9, :o3, 811868400
          tz.transition 1996, 3, :o4, 828198000
          tz.transition 1996, 10, :o3, 846342000
          tz.transition 1997, 3, :o5, 859647600
          tz.transition 1997, 10, :o6, 877795200
          tz.transition 1998, 3, :o5, 891100800
          tz.transition 1998, 10, :o6, 909244800
          tz.transition 1999, 3, :o5, 922550400
          tz.transition 1999, 10, :o6, 941299200
          tz.transition 2000, 3, :o5, 954000000
          tz.transition 2000, 10, :o6, 972748800
          tz.transition 2001, 3, :o5, 985449600
          tz.transition 2001, 10, :o6, 1004198400
          tz.transition 2002, 3, :o5, 1017504000
          tz.transition 2002, 10, :o6, 1035648000
          tz.transition 2003, 3, :o5, 1048953600
          tz.transition 2003, 10, :o6, 1067097600
          tz.transition 2004, 3, :o5, 1080403200
          tz.transition 2004, 10, :o6, 1099152000
          tz.transition 2005, 3, :o5, 1111852800
          tz.transition 2005, 10, :o6, 1130601600
          tz.transition 2006, 3, :o5, 1143302400
          tz.transition 2006, 10, :o6, 1162051200
          tz.transition 2007, 3, :o5, 1174752000
          tz.transition 2007, 10, :o6, 1193500800
          tz.transition 2008, 3, :o5, 1206806400
          tz.transition 2008, 10, :o6, 1224950400
          tz.transition 2009, 3, :o5, 1238256000
          tz.transition 2009, 10, :o6, 1256400000
          tz.transition 2010, 3, :o5, 1269705600
          tz.transition 2010, 10, :o6, 1288454400
          tz.transition 2011, 3, :o5, 1301155200
          tz.transition 2011, 10, :o6, 1319904000
          tz.transition 2012, 3, :o5, 1332604800
          tz.transition 2012, 10, :o6, 1351353600
          tz.transition 2013, 3, :o5, 1364659200
          tz.transition 2013, 10, :o6, 1382803200
          tz.transition 2014, 3, :o5, 1396108800
          tz.transition 2014, 10, :o6, 1414252800
          tz.transition 2015, 3, :o5, 1427558400
          tz.transition 2015, 10, :o6, 1445702400
          tz.transition 2016, 3, :o5, 1459008000
          tz.transition 2016, 10, :o6, 1477756800
          tz.transition 2017, 3, :o5, 1490457600
          tz.transition 2017, 10, :o6, 1509206400
          tz.transition 2018, 3, :o5, 1521907200
          tz.transition 2018, 10, :o6, 1540656000
          tz.transition 2019, 3, :o5, 1553961600
          tz.transition 2019, 10, :o6, 1572105600
          tz.transition 2020, 3, :o5, 1585411200
          tz.transition 2020, 10, :o6, 1603555200
          tz.transition 2021, 3, :o5, 1616860800
          tz.transition 2021, 10, :o6, 1635609600
          tz.transition 2022, 3, :o5, 1648310400
          tz.transition 2022, 10, :o6, 1667059200
          tz.transition 2023, 3, :o5, 1679760000
          tz.transition 2023, 10, :o6, 1698508800
          tz.transition 2024, 3, :o5, 1711814400
          tz.transition 2024, 10, :o6, 1729958400
          tz.transition 2025, 3, :o5, 1743264000
          tz.transition 2025, 10, :o6, 1761408000
          tz.transition 2026, 3, :o5, 1774713600
          tz.transition 2026, 10, :o6, 1792857600
          tz.transition 2027, 3, :o5, 1806163200
          tz.transition 2027, 10, :o6, 1824912000
          tz.transition 2028, 3, :o5, 1837612800
          tz.transition 2028, 10, :o6, 1856361600
          tz.transition 2029, 3, :o5, 1869062400
          tz.transition 2029, 10, :o6, 1887811200
          tz.transition 2030, 3, :o5, 1901116800
          tz.transition 2030, 10, :o6, 1919260800
          tz.transition 2031, 3, :o5, 1932566400
          tz.transition 2031, 10, :o6, 1950710400
          tz.transition 2032, 3, :o5, 1964016000
          tz.transition 2032, 10, :o6, 1982764800
          tz.transition 2033, 3, :o5, 1995465600
          tz.transition 2033, 10, :o6, 2014214400
          tz.transition 2034, 3, :o5, 2026915200
          tz.transition 2034, 10, :o6, 2045664000
          tz.transition 2035, 3, :o5, 2058364800
          tz.transition 2035, 10, :o6, 2077113600
          tz.transition 2036, 3, :o5, 2090419200
          tz.transition 2036, 10, :o6, 2108563200
          tz.transition 2037, 3, :o5, 2121868800
          tz.transition 2037, 10, :o6, 2140012800
          tz.transition 2038, 3, :o5, 14793061, 6
          tz.transition 2038, 10, :o6, 14794363, 6
          tz.transition 2039, 3, :o5, 14795245, 6
          tz.transition 2039, 10, :o6, 14796547, 6
          tz.transition 2040, 3, :o5, 14797429, 6
          tz.transition 2040, 10, :o6, 14798731, 6
          tz.transition 2041, 3, :o5, 14799655, 6
          tz.transition 2041, 10, :o6, 14800915, 6
          tz.transition 2042, 3, :o5, 14801839, 6
          tz.transition 2042, 10, :o6, 14803099, 6
          tz.transition 2043, 3, :o5, 14804023, 6
          tz.transition 2043, 10, :o6, 14805283, 6
          tz.transition 2044, 3, :o5, 14806207, 6
          tz.transition 2044, 10, :o6, 14807509, 6
          tz.transition 2045, 3, :o5, 14808391, 6
          tz.transition 2045, 10, :o6, 14809693, 6
          tz.transition 2046, 3, :o5, 14810575, 6
          tz.transition 2046, 10, :o6, 14811877, 6
          tz.transition 2047, 3, :o5, 14812801, 6
          tz.transition 2047, 10, :o6, 14814061, 6
          tz.transition 2048, 3, :o5, 14814985, 6
          tz.transition 2048, 10, :o6, 14816245, 6
          tz.transition 2049, 3, :o5, 14817169, 6
          tz.transition 2049, 10, :o6, 14818471, 6
          tz.transition 2050, 3, :o5, 14819353, 6
          tz.transition 2050, 10, :o6, 14820655, 6
        end
      end
    end
  end
end
