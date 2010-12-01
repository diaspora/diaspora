module TZInfo
  module Definitions
    module MET
      include TimezoneDefinition
      
      timezone 'MET' do |tz|
        tz.offset :o0, 3600, 0, :MET
        tz.offset :o1, 3600, 3600, :MEST
        
        tz.transition 1916, 4, :o1, 29051813, 12
        tz.transition 1916, 9, :o0, 58107299, 24
        tz.transition 1917, 4, :o1, 58112029, 24
        tz.transition 1917, 9, :o0, 58115725, 24
        tz.transition 1918, 4, :o1, 58120765, 24
        tz.transition 1918, 9, :o0, 58124461, 24
        tz.transition 1940, 4, :o1, 58313293, 24
        tz.transition 1942, 11, :o0, 58335973, 24
        tz.transition 1943, 3, :o1, 58339501, 24
        tz.transition 1943, 10, :o0, 58344037, 24
        tz.transition 1944, 4, :o1, 58348405, 24
        tz.transition 1944, 10, :o0, 58352773, 24
        tz.transition 1945, 4, :o1, 58357141, 24
        tz.transition 1945, 9, :o0, 58361149, 24
        tz.transition 1977, 4, :o1, 228877200
        tz.transition 1977, 9, :o0, 243997200
        tz.transition 1978, 4, :o1, 260326800
        tz.transition 1978, 10, :o0, 276051600
        tz.transition 1979, 4, :o1, 291776400
        tz.transition 1979, 9, :o0, 307501200
        tz.transition 1980, 4, :o1, 323830800
        tz.transition 1980, 9, :o0, 338950800
        tz.transition 1981, 3, :o1, 354675600
        tz.transition 1981, 9, :o0, 370400400
        tz.transition 1982, 3, :o1, 386125200
        tz.transition 1982, 9, :o0, 401850000
        tz.transition 1983, 3, :o1, 417574800
        tz.transition 1983, 9, :o0, 433299600
        tz.transition 1984, 3, :o1, 449024400
        tz.transition 1984, 9, :o0, 465354000
        tz.transition 1985, 3, :o1, 481078800
        tz.transition 1985, 9, :o0, 496803600
        tz.transition 1986, 3, :o1, 512528400
        tz.transition 1986, 9, :o0, 528253200
        tz.transition 1987, 3, :o1, 543978000
        tz.transition 1987, 9, :o0, 559702800
        tz.transition 1988, 3, :o1, 575427600
        tz.transition 1988, 9, :o0, 591152400
        tz.transition 1989, 3, :o1, 606877200
        tz.transition 1989, 9, :o0, 622602000
        tz.transition 1990, 3, :o1, 638326800
        tz.transition 1990, 9, :o0, 654656400
        tz.transition 1991, 3, :o1, 670381200
        tz.transition 1991, 9, :o0, 686106000
        tz.transition 1992, 3, :o1, 701830800
        tz.transition 1992, 9, :o0, 717555600
        tz.transition 1993, 3, :o1, 733280400
        tz.transition 1993, 9, :o0, 749005200
        tz.transition 1994, 3, :o1, 764730000
        tz.transition 1994, 9, :o0, 780454800
        tz.transition 1995, 3, :o1, 796179600
        tz.transition 1995, 9, :o0, 811904400
        tz.transition 1996, 3, :o1, 828234000
        tz.transition 1996, 10, :o0, 846378000
        tz.transition 1997, 3, :o1, 859683600
        tz.transition 1997, 10, :o0, 877827600
        tz.transition 1998, 3, :o1, 891133200
        tz.transition 1998, 10, :o0, 909277200
        tz.transition 1999, 3, :o1, 922582800
        tz.transition 1999, 10, :o0, 941331600
        tz.transition 2000, 3, :o1, 954032400
        tz.transition 2000, 10, :o0, 972781200
        tz.transition 2001, 3, :o1, 985482000
        tz.transition 2001, 10, :o0, 1004230800
        tz.transition 2002, 3, :o1, 1017536400
        tz.transition 2002, 10, :o0, 1035680400
        tz.transition 2003, 3, :o1, 1048986000
        tz.transition 2003, 10, :o0, 1067130000
        tz.transition 2004, 3, :o1, 1080435600
        tz.transition 2004, 10, :o0, 1099184400
        tz.transition 2005, 3, :o1, 1111885200
        tz.transition 2005, 10, :o0, 1130634000
        tz.transition 2006, 3, :o1, 1143334800
        tz.transition 2006, 10, :o0, 1162083600
        tz.transition 2007, 3, :o1, 1174784400
        tz.transition 2007, 10, :o0, 1193533200
        tz.transition 2008, 3, :o1, 1206838800
        tz.transition 2008, 10, :o0, 1224982800
        tz.transition 2009, 3, :o1, 1238288400
        tz.transition 2009, 10, :o0, 1256432400
        tz.transition 2010, 3, :o1, 1269738000
        tz.transition 2010, 10, :o0, 1288486800
        tz.transition 2011, 3, :o1, 1301187600
        tz.transition 2011, 10, :o0, 1319936400
        tz.transition 2012, 3, :o1, 1332637200
        tz.transition 2012, 10, :o0, 1351386000
        tz.transition 2013, 3, :o1, 1364691600
        tz.transition 2013, 10, :o0, 1382835600
        tz.transition 2014, 3, :o1, 1396141200
        tz.transition 2014, 10, :o0, 1414285200
        tz.transition 2015, 3, :o1, 1427590800
        tz.transition 2015, 10, :o0, 1445734800
        tz.transition 2016, 3, :o1, 1459040400
        tz.transition 2016, 10, :o0, 1477789200
        tz.transition 2017, 3, :o1, 1490490000
        tz.transition 2017, 10, :o0, 1509238800
        tz.transition 2018, 3, :o1, 1521939600
        tz.transition 2018, 10, :o0, 1540688400
        tz.transition 2019, 3, :o1, 1553994000
        tz.transition 2019, 10, :o0, 1572138000
        tz.transition 2020, 3, :o1, 1585443600
        tz.transition 2020, 10, :o0, 1603587600
        tz.transition 2021, 3, :o1, 1616893200
        tz.transition 2021, 10, :o0, 1635642000
        tz.transition 2022, 3, :o1, 1648342800
        tz.transition 2022, 10, :o0, 1667091600
        tz.transition 2023, 3, :o1, 1679792400
        tz.transition 2023, 10, :o0, 1698541200
        tz.transition 2024, 3, :o1, 1711846800
        tz.transition 2024, 10, :o0, 1729990800
        tz.transition 2025, 3, :o1, 1743296400
        tz.transition 2025, 10, :o0, 1761440400
        tz.transition 2026, 3, :o1, 1774746000
        tz.transition 2026, 10, :o0, 1792890000
        tz.transition 2027, 3, :o1, 1806195600
        tz.transition 2027, 10, :o0, 1824944400
        tz.transition 2028, 3, :o1, 1837645200
        tz.transition 2028, 10, :o0, 1856394000
        tz.transition 2029, 3, :o1, 1869094800
        tz.transition 2029, 10, :o0, 1887843600
        tz.transition 2030, 3, :o1, 1901149200
        tz.transition 2030, 10, :o0, 1919293200
        tz.transition 2031, 3, :o1, 1932598800
        tz.transition 2031, 10, :o0, 1950742800
        tz.transition 2032, 3, :o1, 1964048400
        tz.transition 2032, 10, :o0, 1982797200
        tz.transition 2033, 3, :o1, 1995498000
        tz.transition 2033, 10, :o0, 2014246800
        tz.transition 2034, 3, :o1, 2026947600
        tz.transition 2034, 10, :o0, 2045696400
        tz.transition 2035, 3, :o1, 2058397200
        tz.transition 2035, 10, :o0, 2077146000
        tz.transition 2036, 3, :o1, 2090451600
        tz.transition 2036, 10, :o0, 2108595600
        tz.transition 2037, 3, :o1, 2121901200
        tz.transition 2037, 10, :o0, 2140045200
        tz.transition 2038, 3, :o1, 59172253, 24
        tz.transition 2038, 10, :o0, 59177461, 24
        tz.transition 2039, 3, :o1, 59180989, 24
        tz.transition 2039, 10, :o0, 59186197, 24
        tz.transition 2040, 3, :o1, 59189725, 24
        tz.transition 2040, 10, :o0, 59194933, 24
        tz.transition 2041, 3, :o1, 59198629, 24
        tz.transition 2041, 10, :o0, 59203669, 24
        tz.transition 2042, 3, :o1, 59207365, 24
        tz.transition 2042, 10, :o0, 59212405, 24
        tz.transition 2043, 3, :o1, 59216101, 24
        tz.transition 2043, 10, :o0, 59221141, 24
        tz.transition 2044, 3, :o1, 59224837, 24
        tz.transition 2044, 10, :o0, 59230045, 24
        tz.transition 2045, 3, :o1, 59233573, 24
        tz.transition 2045, 10, :o0, 59238781, 24
        tz.transition 2046, 3, :o1, 59242309, 24
        tz.transition 2046, 10, :o0, 59247517, 24
        tz.transition 2047, 3, :o1, 59251213, 24
        tz.transition 2047, 10, :o0, 59256253, 24
        tz.transition 2048, 3, :o1, 59259949, 24
        tz.transition 2048, 10, :o0, 59264989, 24
        tz.transition 2049, 3, :o1, 59268685, 24
        tz.transition 2049, 10, :o0, 59273893, 24
        tz.transition 2050, 3, :o1, 59277421, 24
        tz.transition 2050, 10, :o0, 59282629, 24
      end
    end
  end
end
