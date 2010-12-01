module TZInfo
  module Definitions
    module Europe
      module Sofia
        include TimezoneDefinition
        
        timezone 'Europe/Sofia' do |tz|
          tz.offset :o0, 5596, 0, :LMT
          tz.offset :o1, 7016, 0, :IMT
          tz.offset :o2, 7200, 0, :EET
          tz.offset :o3, 3600, 0, :CET
          tz.offset :o4, 3600, 3600, :CEST
          tz.offset :o5, 7200, 3600, :EEST
          
          tz.transition 1879, 12, :o1, 52006653401, 21600
          tz.transition 1894, 11, :o2, 26062154123, 10800
          tz.transition 1942, 11, :o3, 58335973, 24
          tz.transition 1943, 3, :o4, 58339501, 24
          tz.transition 1943, 10, :o3, 58344037, 24
          tz.transition 1944, 4, :o4, 58348405, 24
          tz.transition 1944, 10, :o3, 58352773, 24
          tz.transition 1945, 4, :o2, 29178571, 12
          tz.transition 1979, 3, :o5, 291762000
          tz.transition 1979, 9, :o2, 307576800
          tz.transition 1980, 4, :o5, 323816400
          tz.transition 1980, 9, :o2, 339026400
          tz.transition 1981, 4, :o5, 355266000
          tz.transition 1981, 9, :o2, 370393200
          tz.transition 1982, 4, :o5, 386715600
          tz.transition 1982, 9, :o2, 401846400
          tz.transition 1983, 3, :o5, 417571200
          tz.transition 1983, 9, :o2, 433296000
          tz.transition 1984, 3, :o5, 449020800
          tz.transition 1984, 9, :o2, 465350400
          tz.transition 1985, 3, :o5, 481075200
          tz.transition 1985, 9, :o2, 496800000
          tz.transition 1986, 3, :o5, 512524800
          tz.transition 1986, 9, :o2, 528249600
          tz.transition 1987, 3, :o5, 543974400
          tz.transition 1987, 9, :o2, 559699200
          tz.transition 1988, 3, :o5, 575424000
          tz.transition 1988, 9, :o2, 591148800
          tz.transition 1989, 3, :o5, 606873600
          tz.transition 1989, 9, :o2, 622598400
          tz.transition 1990, 3, :o5, 638323200
          tz.transition 1990, 9, :o2, 654652800
          tz.transition 1991, 3, :o5, 670370400
          tz.transition 1991, 9, :o2, 686091600
          tz.transition 1992, 3, :o5, 701820000
          tz.transition 1992, 9, :o2, 717541200
          tz.transition 1993, 3, :o5, 733269600
          tz.transition 1993, 9, :o2, 748990800
          tz.transition 1994, 3, :o5, 764719200
          tz.transition 1994, 9, :o2, 780440400
          tz.transition 1995, 3, :o5, 796168800
          tz.transition 1995, 9, :o2, 811890000
          tz.transition 1996, 3, :o5, 828223200
          tz.transition 1996, 10, :o2, 846363600
          tz.transition 1997, 3, :o5, 859683600
          tz.transition 1997, 10, :o2, 877827600
          tz.transition 1998, 3, :o5, 891133200
          tz.transition 1998, 10, :o2, 909277200
          tz.transition 1999, 3, :o5, 922582800
          tz.transition 1999, 10, :o2, 941331600
          tz.transition 2000, 3, :o5, 954032400
          tz.transition 2000, 10, :o2, 972781200
          tz.transition 2001, 3, :o5, 985482000
          tz.transition 2001, 10, :o2, 1004230800
          tz.transition 2002, 3, :o5, 1017536400
          tz.transition 2002, 10, :o2, 1035680400
          tz.transition 2003, 3, :o5, 1048986000
          tz.transition 2003, 10, :o2, 1067130000
          tz.transition 2004, 3, :o5, 1080435600
          tz.transition 2004, 10, :o2, 1099184400
          tz.transition 2005, 3, :o5, 1111885200
          tz.transition 2005, 10, :o2, 1130634000
          tz.transition 2006, 3, :o5, 1143334800
          tz.transition 2006, 10, :o2, 1162083600
          tz.transition 2007, 3, :o5, 1174784400
          tz.transition 2007, 10, :o2, 1193533200
          tz.transition 2008, 3, :o5, 1206838800
          tz.transition 2008, 10, :o2, 1224982800
          tz.transition 2009, 3, :o5, 1238288400
          tz.transition 2009, 10, :o2, 1256432400
          tz.transition 2010, 3, :o5, 1269738000
          tz.transition 2010, 10, :o2, 1288486800
          tz.transition 2011, 3, :o5, 1301187600
          tz.transition 2011, 10, :o2, 1319936400
          tz.transition 2012, 3, :o5, 1332637200
          tz.transition 2012, 10, :o2, 1351386000
          tz.transition 2013, 3, :o5, 1364691600
          tz.transition 2013, 10, :o2, 1382835600
          tz.transition 2014, 3, :o5, 1396141200
          tz.transition 2014, 10, :o2, 1414285200
          tz.transition 2015, 3, :o5, 1427590800
          tz.transition 2015, 10, :o2, 1445734800
          tz.transition 2016, 3, :o5, 1459040400
          tz.transition 2016, 10, :o2, 1477789200
          tz.transition 2017, 3, :o5, 1490490000
          tz.transition 2017, 10, :o2, 1509238800
          tz.transition 2018, 3, :o5, 1521939600
          tz.transition 2018, 10, :o2, 1540688400
          tz.transition 2019, 3, :o5, 1553994000
          tz.transition 2019, 10, :o2, 1572138000
          tz.transition 2020, 3, :o5, 1585443600
          tz.transition 2020, 10, :o2, 1603587600
          tz.transition 2021, 3, :o5, 1616893200
          tz.transition 2021, 10, :o2, 1635642000
          tz.transition 2022, 3, :o5, 1648342800
          tz.transition 2022, 10, :o2, 1667091600
          tz.transition 2023, 3, :o5, 1679792400
          tz.transition 2023, 10, :o2, 1698541200
          tz.transition 2024, 3, :o5, 1711846800
          tz.transition 2024, 10, :o2, 1729990800
          tz.transition 2025, 3, :o5, 1743296400
          tz.transition 2025, 10, :o2, 1761440400
          tz.transition 2026, 3, :o5, 1774746000
          tz.transition 2026, 10, :o2, 1792890000
          tz.transition 2027, 3, :o5, 1806195600
          tz.transition 2027, 10, :o2, 1824944400
          tz.transition 2028, 3, :o5, 1837645200
          tz.transition 2028, 10, :o2, 1856394000
          tz.transition 2029, 3, :o5, 1869094800
          tz.transition 2029, 10, :o2, 1887843600
          tz.transition 2030, 3, :o5, 1901149200
          tz.transition 2030, 10, :o2, 1919293200
          tz.transition 2031, 3, :o5, 1932598800
          tz.transition 2031, 10, :o2, 1950742800
          tz.transition 2032, 3, :o5, 1964048400
          tz.transition 2032, 10, :o2, 1982797200
          tz.transition 2033, 3, :o5, 1995498000
          tz.transition 2033, 10, :o2, 2014246800
          tz.transition 2034, 3, :o5, 2026947600
          tz.transition 2034, 10, :o2, 2045696400
          tz.transition 2035, 3, :o5, 2058397200
          tz.transition 2035, 10, :o2, 2077146000
          tz.transition 2036, 3, :o5, 2090451600
          tz.transition 2036, 10, :o2, 2108595600
          tz.transition 2037, 3, :o5, 2121901200
          tz.transition 2037, 10, :o2, 2140045200
          tz.transition 2038, 3, :o5, 59172253, 24
          tz.transition 2038, 10, :o2, 59177461, 24
          tz.transition 2039, 3, :o5, 59180989, 24
          tz.transition 2039, 10, :o2, 59186197, 24
          tz.transition 2040, 3, :o5, 59189725, 24
          tz.transition 2040, 10, :o2, 59194933, 24
          tz.transition 2041, 3, :o5, 59198629, 24
          tz.transition 2041, 10, :o2, 59203669, 24
          tz.transition 2042, 3, :o5, 59207365, 24
          tz.transition 2042, 10, :o2, 59212405, 24
          tz.transition 2043, 3, :o5, 59216101, 24
          tz.transition 2043, 10, :o2, 59221141, 24
          tz.transition 2044, 3, :o5, 59224837, 24
          tz.transition 2044, 10, :o2, 59230045, 24
          tz.transition 2045, 3, :o5, 59233573, 24
          tz.transition 2045, 10, :o2, 59238781, 24
          tz.transition 2046, 3, :o5, 59242309, 24
          tz.transition 2046, 10, :o2, 59247517, 24
          tz.transition 2047, 3, :o5, 59251213, 24
          tz.transition 2047, 10, :o2, 59256253, 24
          tz.transition 2048, 3, :o5, 59259949, 24
          tz.transition 2048, 10, :o2, 59264989, 24
          tz.transition 2049, 3, :o5, 59268685, 24
          tz.transition 2049, 10, :o2, 59273893, 24
          tz.transition 2050, 3, :o5, 59277421, 24
          tz.transition 2050, 10, :o2, 59282629, 24
        end
      end
    end
  end
end
