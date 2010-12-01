module TZInfo
  module Definitions
    module Atlantic
      module Madeira
        include TimezoneDefinition
        
        timezone 'Atlantic/Madeira' do |tz|
          tz.offset :o0, -4056, 0, :LMT
          tz.offset :o1, -4056, 0, :FMT
          tz.offset :o2, -3600, 0, :MADT
          tz.offset :o3, -3600, 3600, :MADST
          tz.offset :o4, -3600, 7200, :MADMT
          tz.offset :o5, 0, 0, :WET
          tz.offset :o6, 0, 3600, :WEST
          
          tz.transition 1884, 1, :o1, 8673035569, 3600
          tz.transition 1911, 5, :o2, 8709049969, 3600
          tz.transition 1916, 6, :o3, 4842065, 2
          tz.transition 1916, 11, :o2, 58108045, 24
          tz.transition 1917, 3, :o3, 4842577, 2
          tz.transition 1917, 10, :o2, 4843033, 2
          tz.transition 1918, 3, :o3, 4843309, 2
          tz.transition 1918, 10, :o2, 4843763, 2
          tz.transition 1919, 3, :o3, 4844037, 2
          tz.transition 1919, 10, :o2, 4844493, 2
          tz.transition 1920, 3, :o3, 4844769, 2
          tz.transition 1920, 10, :o2, 4845225, 2
          tz.transition 1921, 3, :o3, 4845499, 2
          tz.transition 1921, 10, :o2, 4845955, 2
          tz.transition 1924, 4, :o3, 4847785, 2
          tz.transition 1924, 10, :o2, 4848147, 2
          tz.transition 1926, 4, :o3, 4849247, 2
          tz.transition 1926, 10, :o2, 4849583, 2
          tz.transition 1927, 4, :o3, 4849961, 2
          tz.transition 1927, 10, :o2, 4850311, 2
          tz.transition 1928, 4, :o3, 4850703, 2
          tz.transition 1928, 10, :o2, 4851053, 2
          tz.transition 1929, 4, :o3, 4851445, 2
          tz.transition 1929, 10, :o2, 4851781, 2
          tz.transition 1931, 4, :o3, 4852901, 2
          tz.transition 1931, 10, :o2, 4853237, 2
          tz.transition 1932, 4, :o3, 4853601, 2
          tz.transition 1932, 10, :o2, 4853965, 2
          tz.transition 1934, 4, :o3, 4855071, 2
          tz.transition 1934, 10, :o2, 4855435, 2
          tz.transition 1935, 3, :o3, 4855785, 2
          tz.transition 1935, 10, :o2, 4856163, 2
          tz.transition 1936, 4, :o3, 4856555, 2
          tz.transition 1936, 10, :o2, 4856891, 2
          tz.transition 1937, 4, :o3, 4857255, 2
          tz.transition 1937, 10, :o2, 4857619, 2
          tz.transition 1938, 3, :o3, 4857969, 2
          tz.transition 1938, 10, :o2, 4858347, 2
          tz.transition 1939, 4, :o3, 4858739, 2
          tz.transition 1939, 11, :o2, 4859173, 2
          tz.transition 1940, 2, :o3, 4859369, 2
          tz.transition 1940, 10, :o2, 4859817, 2
          tz.transition 1941, 4, :o3, 4860181, 2
          tz.transition 1941, 10, :o2, 4860547, 2
          tz.transition 1942, 3, :o3, 4860867, 2
          tz.transition 1942, 4, :o4, 58331411, 24
          tz.transition 1942, 8, :o3, 58334099, 24
          tz.transition 1942, 10, :o2, 4861315, 2
          tz.transition 1943, 3, :o3, 4861595, 2
          tz.transition 1943, 4, :o4, 58339979, 24
          tz.transition 1943, 8, :o3, 58343171, 24
          tz.transition 1943, 10, :o2, 4862057, 2
          tz.transition 1944, 3, :o3, 4862323, 2
          tz.transition 1944, 4, :o4, 58348883, 24
          tz.transition 1944, 8, :o3, 58351907, 24
          tz.transition 1944, 10, :o2, 4862785, 2
          tz.transition 1945, 3, :o3, 4863051, 2
          tz.transition 1945, 4, :o4, 58357619, 24
          tz.transition 1945, 8, :o3, 58360643, 24
          tz.transition 1945, 10, :o2, 4863513, 2
          tz.transition 1946, 4, :o3, 4863835, 2
          tz.transition 1946, 10, :o2, 4864199, 2
          tz.transition 1947, 4, :o3, 19458253, 8
          tz.transition 1947, 10, :o2, 19459709, 8
          tz.transition 1948, 4, :o3, 19461165, 8
          tz.transition 1948, 10, :o2, 19462621, 8
          tz.transition 1949, 4, :o3, 19464077, 8
          tz.transition 1949, 10, :o2, 19465533, 8
          tz.transition 1951, 4, :o3, 19469901, 8
          tz.transition 1951, 10, :o2, 19471413, 8
          tz.transition 1952, 4, :o3, 19472869, 8
          tz.transition 1952, 10, :o2, 19474325, 8
          tz.transition 1953, 4, :o3, 19475781, 8
          tz.transition 1953, 10, :o2, 19477237, 8
          tz.transition 1954, 4, :o3, 19478693, 8
          tz.transition 1954, 10, :o2, 19480149, 8
          tz.transition 1955, 4, :o3, 19481605, 8
          tz.transition 1955, 10, :o2, 19483061, 8
          tz.transition 1956, 4, :o3, 19484517, 8
          tz.transition 1956, 10, :o2, 19486029, 8
          tz.transition 1957, 4, :o3, 19487485, 8
          tz.transition 1957, 10, :o2, 19488941, 8
          tz.transition 1958, 4, :o3, 19490397, 8
          tz.transition 1958, 10, :o2, 19491853, 8
          tz.transition 1959, 4, :o3, 19493309, 8
          tz.transition 1959, 10, :o2, 19494765, 8
          tz.transition 1960, 4, :o3, 19496221, 8
          tz.transition 1960, 10, :o2, 19497677, 8
          tz.transition 1961, 4, :o3, 19499133, 8
          tz.transition 1961, 10, :o2, 19500589, 8
          tz.transition 1962, 4, :o3, 19502045, 8
          tz.transition 1962, 10, :o2, 19503557, 8
          tz.transition 1963, 4, :o3, 19505013, 8
          tz.transition 1963, 10, :o2, 19506469, 8
          tz.transition 1964, 4, :o3, 19507925, 8
          tz.transition 1964, 10, :o2, 19509381, 8
          tz.transition 1965, 4, :o3, 19510837, 8
          tz.transition 1965, 10, :o2, 19512293, 8
          tz.transition 1966, 4, :o5, 19513749, 8
          tz.transition 1977, 3, :o6, 228268800
          tz.transition 1977, 9, :o5, 243993600
          tz.transition 1978, 4, :o6, 260323200
          tz.transition 1978, 10, :o5, 276048000
          tz.transition 1979, 4, :o6, 291772800
          tz.transition 1979, 9, :o5, 307501200
          tz.transition 1980, 3, :o6, 323222400
          tz.transition 1980, 9, :o5, 338950800
          tz.transition 1981, 3, :o6, 354675600
          tz.transition 1981, 9, :o5, 370400400
          tz.transition 1982, 3, :o6, 386125200
          tz.transition 1982, 9, :o5, 401850000
          tz.transition 1983, 3, :o6, 417578400
          tz.transition 1983, 9, :o5, 433299600
          tz.transition 1984, 3, :o6, 449024400
          tz.transition 1984, 9, :o5, 465354000
          tz.transition 1985, 3, :o6, 481078800
          tz.transition 1985, 9, :o5, 496803600
          tz.transition 1986, 3, :o6, 512528400
          tz.transition 1986, 9, :o5, 528253200
          tz.transition 1987, 3, :o6, 543978000
          tz.transition 1987, 9, :o5, 559702800
          tz.transition 1988, 3, :o6, 575427600
          tz.transition 1988, 9, :o5, 591152400
          tz.transition 1989, 3, :o6, 606877200
          tz.transition 1989, 9, :o5, 622602000
          tz.transition 1990, 3, :o6, 638326800
          tz.transition 1990, 9, :o5, 654656400
          tz.transition 1991, 3, :o6, 670381200
          tz.transition 1991, 9, :o5, 686106000
          tz.transition 1992, 3, :o6, 701830800
          tz.transition 1992, 9, :o5, 717555600
          tz.transition 1993, 3, :o6, 733280400
          tz.transition 1993, 9, :o5, 749005200
          tz.transition 1994, 3, :o6, 764730000
          tz.transition 1994, 9, :o5, 780454800
          tz.transition 1995, 3, :o6, 796179600
          tz.transition 1995, 9, :o5, 811904400
          tz.transition 1996, 3, :o6, 828234000
          tz.transition 1996, 10, :o5, 846378000
          tz.transition 1997, 3, :o6, 859683600
          tz.transition 1997, 10, :o5, 877827600
          tz.transition 1998, 3, :o6, 891133200
          tz.transition 1998, 10, :o5, 909277200
          tz.transition 1999, 3, :o6, 922582800
          tz.transition 1999, 10, :o5, 941331600
          tz.transition 2000, 3, :o6, 954032400
          tz.transition 2000, 10, :o5, 972781200
          tz.transition 2001, 3, :o6, 985482000
          tz.transition 2001, 10, :o5, 1004230800
          tz.transition 2002, 3, :o6, 1017536400
          tz.transition 2002, 10, :o5, 1035680400
          tz.transition 2003, 3, :o6, 1048986000
          tz.transition 2003, 10, :o5, 1067130000
          tz.transition 2004, 3, :o6, 1080435600
          tz.transition 2004, 10, :o5, 1099184400
          tz.transition 2005, 3, :o6, 1111885200
          tz.transition 2005, 10, :o5, 1130634000
          tz.transition 2006, 3, :o6, 1143334800
          tz.transition 2006, 10, :o5, 1162083600
          tz.transition 2007, 3, :o6, 1174784400
          tz.transition 2007, 10, :o5, 1193533200
          tz.transition 2008, 3, :o6, 1206838800
          tz.transition 2008, 10, :o5, 1224982800
          tz.transition 2009, 3, :o6, 1238288400
          tz.transition 2009, 10, :o5, 1256432400
          tz.transition 2010, 3, :o6, 1269738000
          tz.transition 2010, 10, :o5, 1288486800
          tz.transition 2011, 3, :o6, 1301187600
          tz.transition 2011, 10, :o5, 1319936400
          tz.transition 2012, 3, :o6, 1332637200
          tz.transition 2012, 10, :o5, 1351386000
          tz.transition 2013, 3, :o6, 1364691600
          tz.transition 2013, 10, :o5, 1382835600
          tz.transition 2014, 3, :o6, 1396141200
          tz.transition 2014, 10, :o5, 1414285200
          tz.transition 2015, 3, :o6, 1427590800
          tz.transition 2015, 10, :o5, 1445734800
          tz.transition 2016, 3, :o6, 1459040400
          tz.transition 2016, 10, :o5, 1477789200
          tz.transition 2017, 3, :o6, 1490490000
          tz.transition 2017, 10, :o5, 1509238800
          tz.transition 2018, 3, :o6, 1521939600
          tz.transition 2018, 10, :o5, 1540688400
          tz.transition 2019, 3, :o6, 1553994000
          tz.transition 2019, 10, :o5, 1572138000
          tz.transition 2020, 3, :o6, 1585443600
          tz.transition 2020, 10, :o5, 1603587600
          tz.transition 2021, 3, :o6, 1616893200
          tz.transition 2021, 10, :o5, 1635642000
          tz.transition 2022, 3, :o6, 1648342800
          tz.transition 2022, 10, :o5, 1667091600
          tz.transition 2023, 3, :o6, 1679792400
          tz.transition 2023, 10, :o5, 1698541200
          tz.transition 2024, 3, :o6, 1711846800
          tz.transition 2024, 10, :o5, 1729990800
          tz.transition 2025, 3, :o6, 1743296400
          tz.transition 2025, 10, :o5, 1761440400
          tz.transition 2026, 3, :o6, 1774746000
          tz.transition 2026, 10, :o5, 1792890000
          tz.transition 2027, 3, :o6, 1806195600
          tz.transition 2027, 10, :o5, 1824944400
          tz.transition 2028, 3, :o6, 1837645200
          tz.transition 2028, 10, :o5, 1856394000
          tz.transition 2029, 3, :o6, 1869094800
          tz.transition 2029, 10, :o5, 1887843600
          tz.transition 2030, 3, :o6, 1901149200
          tz.transition 2030, 10, :o5, 1919293200
          tz.transition 2031, 3, :o6, 1932598800
          tz.transition 2031, 10, :o5, 1950742800
          tz.transition 2032, 3, :o6, 1964048400
          tz.transition 2032, 10, :o5, 1982797200
          tz.transition 2033, 3, :o6, 1995498000
          tz.transition 2033, 10, :o5, 2014246800
          tz.transition 2034, 3, :o6, 2026947600
          tz.transition 2034, 10, :o5, 2045696400
          tz.transition 2035, 3, :o6, 2058397200
          tz.transition 2035, 10, :o5, 2077146000
          tz.transition 2036, 3, :o6, 2090451600
          tz.transition 2036, 10, :o5, 2108595600
          tz.transition 2037, 3, :o6, 2121901200
          tz.transition 2037, 10, :o5, 2140045200
          tz.transition 2038, 3, :o6, 59172253, 24
          tz.transition 2038, 10, :o5, 59177461, 24
          tz.transition 2039, 3, :o6, 59180989, 24
          tz.transition 2039, 10, :o5, 59186197, 24
          tz.transition 2040, 3, :o6, 59189725, 24
          tz.transition 2040, 10, :o5, 59194933, 24
          tz.transition 2041, 3, :o6, 59198629, 24
          tz.transition 2041, 10, :o5, 59203669, 24
          tz.transition 2042, 3, :o6, 59207365, 24
          tz.transition 2042, 10, :o5, 59212405, 24
          tz.transition 2043, 3, :o6, 59216101, 24
          tz.transition 2043, 10, :o5, 59221141, 24
          tz.transition 2044, 3, :o6, 59224837, 24
          tz.transition 2044, 10, :o5, 59230045, 24
          tz.transition 2045, 3, :o6, 59233573, 24
          tz.transition 2045, 10, :o5, 59238781, 24
          tz.transition 2046, 3, :o6, 59242309, 24
          tz.transition 2046, 10, :o5, 59247517, 24
          tz.transition 2047, 3, :o6, 59251213, 24
          tz.transition 2047, 10, :o5, 59256253, 24
          tz.transition 2048, 3, :o6, 59259949, 24
          tz.transition 2048, 10, :o5, 59264989, 24
          tz.transition 2049, 3, :o6, 59268685, 24
          tz.transition 2049, 10, :o5, 59273893, 24
          tz.transition 2050, 3, :o6, 59277421, 24
          tz.transition 2050, 10, :o5, 59282629, 24
        end
      end
    end
  end
end
