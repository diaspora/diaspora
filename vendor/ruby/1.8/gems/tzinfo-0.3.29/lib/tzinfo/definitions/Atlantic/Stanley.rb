module TZInfo
  module Definitions
    module Atlantic
      module Stanley
        include TimezoneDefinition
        
        timezone 'Atlantic/Stanley' do |tz|
          tz.offset :o0, -13884, 0, :LMT
          tz.offset :o1, -13884, 0, :SMT
          tz.offset :o2, -14400, 0, :FKT
          tz.offset :o3, -14400, 3600, :FKST
          tz.offset :o4, -10800, 0, :FKT
          tz.offset :o5, -10800, 3600, :FKST
          
          tz.transition 1890, 1, :o1, 17361854357, 7200
          tz.transition 1912, 3, :o2, 17420210357, 7200
          tz.transition 1937, 9, :o3, 7286408, 3
          tz.transition 1938, 3, :o2, 19431821, 8
          tz.transition 1938, 9, :o3, 7287500, 3
          tz.transition 1939, 3, :o2, 19434733, 8
          tz.transition 1939, 10, :o3, 7288613, 3
          tz.transition 1940, 3, :o2, 19437701, 8
          tz.transition 1940, 9, :o3, 7289705, 3
          tz.transition 1941, 3, :o2, 19440613, 8
          tz.transition 1941, 9, :o3, 7290797, 3
          tz.transition 1942, 3, :o2, 19443525, 8
          tz.transition 1942, 9, :o3, 7291889, 3
          tz.transition 1943, 1, :o2, 19445805, 8
          tz.transition 1983, 5, :o4, 420609600
          tz.transition 1983, 9, :o5, 433306800
          tz.transition 1984, 4, :o4, 452052000
          tz.transition 1984, 9, :o5, 464151600
          tz.transition 1985, 4, :o4, 483501600
          tz.transition 1985, 9, :o3, 495601200
          tz.transition 1986, 4, :o2, 514350000
          tz.transition 1986, 9, :o3, 527054400
          tz.transition 1987, 4, :o2, 545799600
          tz.transition 1987, 9, :o3, 558504000
          tz.transition 1988, 4, :o2, 577249200
          tz.transition 1988, 9, :o3, 589953600
          tz.transition 1989, 4, :o2, 608698800
          tz.transition 1989, 9, :o3, 621403200
          tz.transition 1990, 4, :o2, 640753200
          tz.transition 1990, 9, :o3, 652852800
          tz.transition 1991, 4, :o2, 672202800
          tz.transition 1991, 9, :o3, 684907200
          tz.transition 1992, 4, :o2, 703652400
          tz.transition 1992, 9, :o3, 716356800
          tz.transition 1993, 4, :o2, 735102000
          tz.transition 1993, 9, :o3, 747806400
          tz.transition 1994, 4, :o2, 766551600
          tz.transition 1994, 9, :o3, 779256000
          tz.transition 1995, 4, :o2, 798001200
          tz.transition 1995, 9, :o3, 810705600
          tz.transition 1996, 4, :o2, 830055600
          tz.transition 1996, 9, :o3, 842760000
          tz.transition 1997, 4, :o2, 861505200
          tz.transition 1997, 9, :o3, 874209600
          tz.transition 1998, 4, :o2, 892954800
          tz.transition 1998, 9, :o3, 905659200
          tz.transition 1999, 4, :o2, 924404400
          tz.transition 1999, 9, :o3, 937108800
          tz.transition 2000, 4, :o2, 955854000
          tz.transition 2000, 9, :o3, 968558400
          tz.transition 2001, 4, :o2, 987310800
          tz.transition 2001, 9, :o3, 999410400
          tz.transition 2002, 4, :o2, 1019365200
          tz.transition 2002, 9, :o3, 1030860000
          tz.transition 2003, 4, :o2, 1050814800
          tz.transition 2003, 9, :o3, 1062914400
          tz.transition 2004, 4, :o2, 1082264400
          tz.transition 2004, 9, :o3, 1094364000
          tz.transition 2005, 4, :o2, 1113714000
          tz.transition 2005, 9, :o3, 1125813600
          tz.transition 2006, 4, :o2, 1145163600
          tz.transition 2006, 9, :o3, 1157263200
          tz.transition 2007, 4, :o2, 1176613200
          tz.transition 2007, 9, :o3, 1188712800
          tz.transition 2008, 4, :o2, 1208667600
          tz.transition 2008, 9, :o3, 1220767200
          tz.transition 2009, 4, :o2, 1240117200
          tz.transition 2009, 9, :o3, 1252216800
          tz.transition 2010, 4, :o2, 1271566800
          tz.transition 2010, 9, :o3, 1283666400
          tz.transition 2012, 4, :o2, 1334466000
          tz.transition 2012, 9, :o3, 1346565600
          tz.transition 2013, 4, :o2, 1366520400
          tz.transition 2013, 9, :o3, 1378015200
          tz.transition 2014, 4, :o2, 1397970000
          tz.transition 2014, 9, :o3, 1410069600
          tz.transition 2015, 4, :o2, 1429419600
          tz.transition 2015, 9, :o3, 1441519200
          tz.transition 2016, 4, :o2, 1460869200
          tz.transition 2016, 9, :o3, 1472968800
          tz.transition 2017, 4, :o2, 1492318800
          tz.transition 2017, 9, :o3, 1504418400
          tz.transition 2018, 4, :o2, 1523768400
          tz.transition 2018, 9, :o3, 1535868000
          tz.transition 2019, 4, :o2, 1555822800
          tz.transition 2019, 9, :o3, 1567317600
          tz.transition 2020, 4, :o2, 1587272400
          tz.transition 2020, 9, :o3, 1599372000
          tz.transition 2021, 4, :o2, 1618722000
          tz.transition 2021, 9, :o3, 1630821600
          tz.transition 2022, 4, :o2, 1650171600
          tz.transition 2022, 9, :o3, 1662271200
          tz.transition 2023, 4, :o2, 1681621200
          tz.transition 2023, 9, :o3, 1693720800
          tz.transition 2024, 4, :o2, 1713675600
          tz.transition 2024, 9, :o3, 1725170400
          tz.transition 2025, 4, :o2, 1745125200
          tz.transition 2025, 9, :o3, 1757224800
          tz.transition 2026, 4, :o2, 1776574800
          tz.transition 2026, 9, :o3, 1788674400
          tz.transition 2027, 4, :o2, 1808024400
          tz.transition 2027, 9, :o3, 1820124000
          tz.transition 2028, 4, :o2, 1839474000
          tz.transition 2028, 9, :o3, 1851573600
          tz.transition 2029, 4, :o2, 1870923600
          tz.transition 2029, 9, :o3, 1883023200
          tz.transition 2030, 4, :o2, 1902978000
          tz.transition 2030, 9, :o3, 1914472800
          tz.transition 2031, 4, :o2, 1934427600
          tz.transition 2031, 9, :o3, 1946527200
          tz.transition 2032, 4, :o2, 1965877200
          tz.transition 2032, 9, :o3, 1977976800
          tz.transition 2033, 4, :o2, 1997326800
          tz.transition 2033, 9, :o3, 2009426400
          tz.transition 2034, 4, :o2, 2028776400
          tz.transition 2034, 9, :o3, 2040876000
          tz.transition 2035, 4, :o2, 2060226000
          tz.transition 2035, 9, :o3, 2072325600
          tz.transition 2036, 4, :o2, 2092280400
          tz.transition 2036, 9, :o3, 2104380000
          tz.transition 2037, 4, :o2, 2123730000
          tz.transition 2037, 9, :o3, 2135829600
          tz.transition 2038, 4, :o2, 59172761, 24
          tz.transition 2038, 9, :o3, 9862687, 4
          tz.transition 2039, 4, :o2, 59181497, 24
          tz.transition 2039, 9, :o3, 9864143, 4
          tz.transition 2040, 4, :o2, 59190233, 24
          tz.transition 2040, 9, :o3, 9865599, 4
          tz.transition 2041, 4, :o2, 59199137, 24
          tz.transition 2041, 9, :o3, 9867055, 4
          tz.transition 2042, 4, :o2, 59207873, 24
          tz.transition 2042, 9, :o3, 9868539, 4
          tz.transition 2043, 4, :o2, 59216609, 24
          tz.transition 2043, 9, :o3, 9869995, 4
          tz.transition 2044, 4, :o2, 59225345, 24
          tz.transition 2044, 9, :o3, 9871451, 4
          tz.transition 2045, 4, :o2, 59234081, 24
          tz.transition 2045, 9, :o3, 9872907, 4
          tz.transition 2046, 4, :o2, 59242817, 24
          tz.transition 2046, 9, :o3, 9874363, 4
          tz.transition 2047, 4, :o2, 59251721, 24
          tz.transition 2047, 9, :o3, 9875819, 4
          tz.transition 2048, 4, :o2, 59260457, 24
          tz.transition 2048, 9, :o3, 9877303, 4
          tz.transition 2049, 4, :o2, 59269193, 24
          tz.transition 2049, 9, :o3, 9878759, 4
          tz.transition 2050, 4, :o2, 59277929, 24
        end
      end
    end
  end
end
