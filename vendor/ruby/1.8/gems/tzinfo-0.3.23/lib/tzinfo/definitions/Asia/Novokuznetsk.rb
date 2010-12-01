module TZInfo
  module Definitions
    module Asia
      module Novokuznetsk
        include TimezoneDefinition
        
        timezone 'Asia/Novokuznetsk' do |tz|
          tz.offset :o0, 20928, 0, :NMT
          tz.offset :o1, 21600, 0, :KRAT
          tz.offset :o2, 25200, 0, :KRAT
          tz.offset :o3, 25200, 3600, :KRAST
          tz.offset :o4, 21600, 3600, :KRAST
          tz.offset :o5, 21600, 3600, :NOVST
          tz.offset :o6, 21600, 0, :NOVT
          
          tz.transition 1920, 1, :o1, 545024083, 225
          tz.transition 1930, 6, :o2, 9704593, 4
          tz.transition 1981, 3, :o3, 354906000
          tz.transition 1981, 9, :o2, 370713600
          tz.transition 1982, 3, :o3, 386442000
          tz.transition 1982, 9, :o2, 402249600
          tz.transition 1983, 3, :o3, 417978000
          tz.transition 1983, 9, :o2, 433785600
          tz.transition 1984, 3, :o3, 449600400
          tz.transition 1984, 9, :o2, 465332400
          tz.transition 1985, 3, :o3, 481057200
          tz.transition 1985, 9, :o2, 496782000
          tz.transition 1986, 3, :o3, 512506800
          tz.transition 1986, 9, :o2, 528231600
          tz.transition 1987, 3, :o3, 543956400
          tz.transition 1987, 9, :o2, 559681200
          tz.transition 1988, 3, :o3, 575406000
          tz.transition 1988, 9, :o2, 591130800
          tz.transition 1989, 3, :o3, 606855600
          tz.transition 1989, 9, :o2, 622580400
          tz.transition 1990, 3, :o3, 638305200
          tz.transition 1990, 9, :o2, 654634800
          tz.transition 1991, 3, :o4, 670359600
          tz.transition 1991, 9, :o1, 686088000
          tz.transition 1992, 1, :o2, 695764800
          tz.transition 1992, 3, :o3, 701798400
          tz.transition 1992, 9, :o2, 717519600
          tz.transition 1993, 3, :o3, 733258800
          tz.transition 1993, 9, :o2, 748983600
          tz.transition 1994, 3, :o3, 764708400
          tz.transition 1994, 9, :o2, 780433200
          tz.transition 1995, 3, :o3, 796158000
          tz.transition 1995, 9, :o2, 811882800
          tz.transition 1996, 3, :o3, 828212400
          tz.transition 1996, 10, :o2, 846356400
          tz.transition 1997, 3, :o3, 859662000
          tz.transition 1997, 10, :o2, 877806000
          tz.transition 1998, 3, :o3, 891111600
          tz.transition 1998, 10, :o2, 909255600
          tz.transition 1999, 3, :o3, 922561200
          tz.transition 1999, 10, :o2, 941310000
          tz.transition 2000, 3, :o3, 954010800
          tz.transition 2000, 10, :o2, 972759600
          tz.transition 2001, 3, :o3, 985460400
          tz.transition 2001, 10, :o2, 1004209200
          tz.transition 2002, 3, :o3, 1017514800
          tz.transition 2002, 10, :o2, 1035658800
          tz.transition 2003, 3, :o3, 1048964400
          tz.transition 2003, 10, :o2, 1067108400
          tz.transition 2004, 3, :o3, 1080414000
          tz.transition 2004, 10, :o2, 1099162800
          tz.transition 2005, 3, :o3, 1111863600
          tz.transition 2005, 10, :o2, 1130612400
          tz.transition 2006, 3, :o3, 1143313200
          tz.transition 2006, 10, :o2, 1162062000
          tz.transition 2007, 3, :o3, 1174762800
          tz.transition 2007, 10, :o2, 1193511600
          tz.transition 2008, 3, :o3, 1206817200
          tz.transition 2008, 10, :o2, 1224961200
          tz.transition 2009, 3, :o3, 1238266800
          tz.transition 2009, 10, :o2, 1256410800
          tz.transition 2010, 3, :o5, 1269716400
          tz.transition 2010, 10, :o6, 1288468800
          tz.transition 2011, 3, :o5, 1301169600
          tz.transition 2011, 10, :o6, 1319918400
          tz.transition 2012, 3, :o5, 1332619200
          tz.transition 2012, 10, :o6, 1351368000
          tz.transition 2013, 3, :o5, 1364673600
          tz.transition 2013, 10, :o6, 1382817600
          tz.transition 2014, 3, :o5, 1396123200
          tz.transition 2014, 10, :o6, 1414267200
          tz.transition 2015, 3, :o5, 1427572800
          tz.transition 2015, 10, :o6, 1445716800
          tz.transition 2016, 3, :o5, 1459022400
          tz.transition 2016, 10, :o6, 1477771200
          tz.transition 2017, 3, :o5, 1490472000
          tz.transition 2017, 10, :o6, 1509220800
          tz.transition 2018, 3, :o5, 1521921600
          tz.transition 2018, 10, :o6, 1540670400
          tz.transition 2019, 3, :o5, 1553976000
          tz.transition 2019, 10, :o6, 1572120000
          tz.transition 2020, 3, :o5, 1585425600
          tz.transition 2020, 10, :o6, 1603569600
          tz.transition 2021, 3, :o5, 1616875200
          tz.transition 2021, 10, :o6, 1635624000
          tz.transition 2022, 3, :o5, 1648324800
          tz.transition 2022, 10, :o6, 1667073600
          tz.transition 2023, 3, :o5, 1679774400
          tz.transition 2023, 10, :o6, 1698523200
          tz.transition 2024, 3, :o5, 1711828800
          tz.transition 2024, 10, :o6, 1729972800
          tz.transition 2025, 3, :o5, 1743278400
          tz.transition 2025, 10, :o6, 1761422400
          tz.transition 2026, 3, :o5, 1774728000
          tz.transition 2026, 10, :o6, 1792872000
          tz.transition 2027, 3, :o5, 1806177600
          tz.transition 2027, 10, :o6, 1824926400
          tz.transition 2028, 3, :o5, 1837627200
          tz.transition 2028, 10, :o6, 1856376000
          tz.transition 2029, 3, :o5, 1869076800
          tz.transition 2029, 10, :o6, 1887825600
          tz.transition 2030, 3, :o5, 1901131200
          tz.transition 2030, 10, :o6, 1919275200
          tz.transition 2031, 3, :o5, 1932580800
          tz.transition 2031, 10, :o6, 1950724800
          tz.transition 2032, 3, :o5, 1964030400
          tz.transition 2032, 10, :o6, 1982779200
          tz.transition 2033, 3, :o5, 1995480000
          tz.transition 2033, 10, :o6, 2014228800
          tz.transition 2034, 3, :o5, 2026929600
          tz.transition 2034, 10, :o6, 2045678400
          tz.transition 2035, 3, :o5, 2058379200
          tz.transition 2035, 10, :o6, 2077128000
          tz.transition 2036, 3, :o5, 2090433600
          tz.transition 2036, 10, :o6, 2108577600
          tz.transition 2037, 3, :o5, 2121883200
          tz.transition 2037, 10, :o6, 2140027200
          tz.transition 2038, 3, :o5, 7396531, 3
          tz.transition 2038, 10, :o6, 7397182, 3
          tz.transition 2039, 3, :o5, 7397623, 3
          tz.transition 2039, 10, :o6, 7398274, 3
          tz.transition 2040, 3, :o5, 7398715, 3
          tz.transition 2040, 10, :o6, 7399366, 3
          tz.transition 2041, 3, :o5, 7399828, 3
          tz.transition 2041, 10, :o6, 7400458, 3
          tz.transition 2042, 3, :o5, 7400920, 3
          tz.transition 2042, 10, :o6, 7401550, 3
          tz.transition 2043, 3, :o5, 7402012, 3
          tz.transition 2043, 10, :o6, 7402642, 3
          tz.transition 2044, 3, :o5, 7403104, 3
          tz.transition 2044, 10, :o6, 7403755, 3
          tz.transition 2045, 3, :o5, 7404196, 3
          tz.transition 2045, 10, :o6, 7404847, 3
          tz.transition 2046, 3, :o5, 7405288, 3
          tz.transition 2046, 10, :o6, 7405939, 3
          tz.transition 2047, 3, :o5, 7406401, 3
          tz.transition 2047, 10, :o6, 7407031, 3
          tz.transition 2048, 3, :o5, 7407493, 3
          tz.transition 2048, 10, :o6, 7408123, 3
          tz.transition 2049, 3, :o5, 7408585, 3
          tz.transition 2049, 10, :o6, 7409236, 3
          tz.transition 2050, 3, :o5, 7409677, 3
          tz.transition 2050, 10, :o6, 7410328, 3
        end
      end
    end
  end
end
