module TZInfo
  module Definitions
    module Asia
      module Omsk
        include TimezoneDefinition
        
        timezone 'Asia/Omsk' do |tz|
          tz.offset :o0, 17616, 0, :LMT
          tz.offset :o1, 18000, 0, :OMST
          tz.offset :o2, 21600, 0, :OMST
          tz.offset :o3, 21600, 3600, :OMSST
          tz.offset :o4, 18000, 3600, :OMSST
          
          tz.transition 1919, 11, :o1, 4360097333, 1800
          tz.transition 1930, 6, :o2, 58227559, 24
          tz.transition 1981, 3, :o3, 354909600
          tz.transition 1981, 9, :o2, 370717200
          tz.transition 1982, 3, :o3, 386445600
          tz.transition 1982, 9, :o2, 402253200
          tz.transition 1983, 3, :o3, 417981600
          tz.transition 1983, 9, :o2, 433789200
          tz.transition 1984, 3, :o3, 449604000
          tz.transition 1984, 9, :o2, 465336000
          tz.transition 1985, 3, :o3, 481060800
          tz.transition 1985, 9, :o2, 496785600
          tz.transition 1986, 3, :o3, 512510400
          tz.transition 1986, 9, :o2, 528235200
          tz.transition 1987, 3, :o3, 543960000
          tz.transition 1987, 9, :o2, 559684800
          tz.transition 1988, 3, :o3, 575409600
          tz.transition 1988, 9, :o2, 591134400
          tz.transition 1989, 3, :o3, 606859200
          tz.transition 1989, 9, :o2, 622584000
          tz.transition 1990, 3, :o3, 638308800
          tz.transition 1990, 9, :o2, 654638400
          tz.transition 1991, 3, :o4, 670363200
          tz.transition 1991, 9, :o1, 686091600
          tz.transition 1992, 1, :o2, 695768400
          tz.transition 1992, 3, :o3, 701802000
          tz.transition 1992, 9, :o2, 717523200
          tz.transition 1993, 3, :o3, 733262400
          tz.transition 1993, 9, :o2, 748987200
          tz.transition 1994, 3, :o3, 764712000
          tz.transition 1994, 9, :o2, 780436800
          tz.transition 1995, 3, :o3, 796161600
          tz.transition 1995, 9, :o2, 811886400
          tz.transition 1996, 3, :o3, 828216000
          tz.transition 1996, 10, :o2, 846360000
          tz.transition 1997, 3, :o3, 859665600
          tz.transition 1997, 10, :o2, 877809600
          tz.transition 1998, 3, :o3, 891115200
          tz.transition 1998, 10, :o2, 909259200
          tz.transition 1999, 3, :o3, 922564800
          tz.transition 1999, 10, :o2, 941313600
          tz.transition 2000, 3, :o3, 954014400
          tz.transition 2000, 10, :o2, 972763200
          tz.transition 2001, 3, :o3, 985464000
          tz.transition 2001, 10, :o2, 1004212800
          tz.transition 2002, 3, :o3, 1017518400
          tz.transition 2002, 10, :o2, 1035662400
          tz.transition 2003, 3, :o3, 1048968000
          tz.transition 2003, 10, :o2, 1067112000
          tz.transition 2004, 3, :o3, 1080417600
          tz.transition 2004, 10, :o2, 1099166400
          tz.transition 2005, 3, :o3, 1111867200
          tz.transition 2005, 10, :o2, 1130616000
          tz.transition 2006, 3, :o3, 1143316800
          tz.transition 2006, 10, :o2, 1162065600
          tz.transition 2007, 3, :o3, 1174766400
          tz.transition 2007, 10, :o2, 1193515200
          tz.transition 2008, 3, :o3, 1206820800
          tz.transition 2008, 10, :o2, 1224964800
          tz.transition 2009, 3, :o3, 1238270400
          tz.transition 2009, 10, :o2, 1256414400
          tz.transition 2010, 3, :o3, 1269720000
          tz.transition 2010, 10, :o2, 1288468800
          tz.transition 2011, 3, :o3, 1301169600
          tz.transition 2011, 10, :o2, 1319918400
          tz.transition 2012, 3, :o3, 1332619200
          tz.transition 2012, 10, :o2, 1351368000
          tz.transition 2013, 3, :o3, 1364673600
          tz.transition 2013, 10, :o2, 1382817600
          tz.transition 2014, 3, :o3, 1396123200
          tz.transition 2014, 10, :o2, 1414267200
          tz.transition 2015, 3, :o3, 1427572800
          tz.transition 2015, 10, :o2, 1445716800
          tz.transition 2016, 3, :o3, 1459022400
          tz.transition 2016, 10, :o2, 1477771200
          tz.transition 2017, 3, :o3, 1490472000
          tz.transition 2017, 10, :o2, 1509220800
          tz.transition 2018, 3, :o3, 1521921600
          tz.transition 2018, 10, :o2, 1540670400
          tz.transition 2019, 3, :o3, 1553976000
          tz.transition 2019, 10, :o2, 1572120000
          tz.transition 2020, 3, :o3, 1585425600
          tz.transition 2020, 10, :o2, 1603569600
          tz.transition 2021, 3, :o3, 1616875200
          tz.transition 2021, 10, :o2, 1635624000
          tz.transition 2022, 3, :o3, 1648324800
          tz.transition 2022, 10, :o2, 1667073600
          tz.transition 2023, 3, :o3, 1679774400
          tz.transition 2023, 10, :o2, 1698523200
          tz.transition 2024, 3, :o3, 1711828800
          tz.transition 2024, 10, :o2, 1729972800
          tz.transition 2025, 3, :o3, 1743278400
          tz.transition 2025, 10, :o2, 1761422400
          tz.transition 2026, 3, :o3, 1774728000
          tz.transition 2026, 10, :o2, 1792872000
          tz.transition 2027, 3, :o3, 1806177600
          tz.transition 2027, 10, :o2, 1824926400
          tz.transition 2028, 3, :o3, 1837627200
          tz.transition 2028, 10, :o2, 1856376000
          tz.transition 2029, 3, :o3, 1869076800
          tz.transition 2029, 10, :o2, 1887825600
          tz.transition 2030, 3, :o3, 1901131200
          tz.transition 2030, 10, :o2, 1919275200
          tz.transition 2031, 3, :o3, 1932580800
          tz.transition 2031, 10, :o2, 1950724800
          tz.transition 2032, 3, :o3, 1964030400
          tz.transition 2032, 10, :o2, 1982779200
          tz.transition 2033, 3, :o3, 1995480000
          tz.transition 2033, 10, :o2, 2014228800
          tz.transition 2034, 3, :o3, 2026929600
          tz.transition 2034, 10, :o2, 2045678400
          tz.transition 2035, 3, :o3, 2058379200
          tz.transition 2035, 10, :o2, 2077128000
          tz.transition 2036, 3, :o3, 2090433600
          tz.transition 2036, 10, :o2, 2108577600
          tz.transition 2037, 3, :o3, 2121883200
          tz.transition 2037, 10, :o2, 2140027200
          tz.transition 2038, 3, :o3, 7396531, 3
          tz.transition 2038, 10, :o2, 7397182, 3
          tz.transition 2039, 3, :o3, 7397623, 3
          tz.transition 2039, 10, :o2, 7398274, 3
          tz.transition 2040, 3, :o3, 7398715, 3
          tz.transition 2040, 10, :o2, 7399366, 3
          tz.transition 2041, 3, :o3, 7399828, 3
          tz.transition 2041, 10, :o2, 7400458, 3
          tz.transition 2042, 3, :o3, 7400920, 3
          tz.transition 2042, 10, :o2, 7401550, 3
          tz.transition 2043, 3, :o3, 7402012, 3
          tz.transition 2043, 10, :o2, 7402642, 3
          tz.transition 2044, 3, :o3, 7403104, 3
          tz.transition 2044, 10, :o2, 7403755, 3
          tz.transition 2045, 3, :o3, 7404196, 3
          tz.transition 2045, 10, :o2, 7404847, 3
          tz.transition 2046, 3, :o3, 7405288, 3
          tz.transition 2046, 10, :o2, 7405939, 3
          tz.transition 2047, 3, :o3, 7406401, 3
          tz.transition 2047, 10, :o2, 7407031, 3
          tz.transition 2048, 3, :o3, 7407493, 3
          tz.transition 2048, 10, :o2, 7408123, 3
          tz.transition 2049, 3, :o3, 7408585, 3
          tz.transition 2049, 10, :o2, 7409236, 3
          tz.transition 2050, 3, :o3, 7409677, 3
          tz.transition 2050, 10, :o2, 7410328, 3
        end
      end
    end
  end
end
