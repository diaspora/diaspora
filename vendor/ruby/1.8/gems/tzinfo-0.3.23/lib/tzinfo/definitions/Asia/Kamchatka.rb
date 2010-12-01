module TZInfo
  module Definitions
    module Asia
      module Kamchatka
        include TimezoneDefinition
        
        timezone 'Asia/Kamchatka' do |tz|
          tz.offset :o0, 38076, 0, :LMT
          tz.offset :o1, 39600, 0, :PETT
          tz.offset :o2, 43200, 0, :PETT
          tz.offset :o3, 43200, 3600, :PETST
          tz.offset :o4, 39600, 3600, :PETST
          
          tz.transition 1922, 11, :o1, 17448250027, 7200
          tz.transition 1930, 6, :o2, 58227553, 24
          tz.transition 1981, 3, :o3, 354888000
          tz.transition 1981, 9, :o2, 370695600
          tz.transition 1982, 3, :o3, 386424000
          tz.transition 1982, 9, :o2, 402231600
          tz.transition 1983, 3, :o3, 417960000
          tz.transition 1983, 9, :o2, 433767600
          tz.transition 1984, 3, :o3, 449582400
          tz.transition 1984, 9, :o2, 465314400
          tz.transition 1985, 3, :o3, 481039200
          tz.transition 1985, 9, :o2, 496764000
          tz.transition 1986, 3, :o3, 512488800
          tz.transition 1986, 9, :o2, 528213600
          tz.transition 1987, 3, :o3, 543938400
          tz.transition 1987, 9, :o2, 559663200
          tz.transition 1988, 3, :o3, 575388000
          tz.transition 1988, 9, :o2, 591112800
          tz.transition 1989, 3, :o3, 606837600
          tz.transition 1989, 9, :o2, 622562400
          tz.transition 1990, 3, :o3, 638287200
          tz.transition 1990, 9, :o2, 654616800
          tz.transition 1991, 3, :o4, 670341600
          tz.transition 1991, 9, :o1, 686070000
          tz.transition 1992, 1, :o2, 695746800
          tz.transition 1992, 3, :o3, 701780400
          tz.transition 1992, 9, :o2, 717501600
          tz.transition 1993, 3, :o3, 733240800
          tz.transition 1993, 9, :o2, 748965600
          tz.transition 1994, 3, :o3, 764690400
          tz.transition 1994, 9, :o2, 780415200
          tz.transition 1995, 3, :o3, 796140000
          tz.transition 1995, 9, :o2, 811864800
          tz.transition 1996, 3, :o3, 828194400
          tz.transition 1996, 10, :o2, 846338400
          tz.transition 1997, 3, :o3, 859644000
          tz.transition 1997, 10, :o2, 877788000
          tz.transition 1998, 3, :o3, 891093600
          tz.transition 1998, 10, :o2, 909237600
          tz.transition 1999, 3, :o3, 922543200
          tz.transition 1999, 10, :o2, 941292000
          tz.transition 2000, 3, :o3, 953992800
          tz.transition 2000, 10, :o2, 972741600
          tz.transition 2001, 3, :o3, 985442400
          tz.transition 2001, 10, :o2, 1004191200
          tz.transition 2002, 3, :o3, 1017496800
          tz.transition 2002, 10, :o2, 1035640800
          tz.transition 2003, 3, :o3, 1048946400
          tz.transition 2003, 10, :o2, 1067090400
          tz.transition 2004, 3, :o3, 1080396000
          tz.transition 2004, 10, :o2, 1099144800
          tz.transition 2005, 3, :o3, 1111845600
          tz.transition 2005, 10, :o2, 1130594400
          tz.transition 2006, 3, :o3, 1143295200
          tz.transition 2006, 10, :o2, 1162044000
          tz.transition 2007, 3, :o3, 1174744800
          tz.transition 2007, 10, :o2, 1193493600
          tz.transition 2008, 3, :o3, 1206799200
          tz.transition 2008, 10, :o2, 1224943200
          tz.transition 2009, 3, :o3, 1238248800
          tz.transition 2009, 10, :o2, 1256392800
          tz.transition 2010, 3, :o4, 1269698400
          tz.transition 2010, 10, :o1, 1288450800
          tz.transition 2011, 3, :o4, 1301151600
          tz.transition 2011, 10, :o1, 1319900400
          tz.transition 2012, 3, :o4, 1332601200
          tz.transition 2012, 10, :o1, 1351350000
          tz.transition 2013, 3, :o4, 1364655600
          tz.transition 2013, 10, :o1, 1382799600
          tz.transition 2014, 3, :o4, 1396105200
          tz.transition 2014, 10, :o1, 1414249200
          tz.transition 2015, 3, :o4, 1427554800
          tz.transition 2015, 10, :o1, 1445698800
          tz.transition 2016, 3, :o4, 1459004400
          tz.transition 2016, 10, :o1, 1477753200
          tz.transition 2017, 3, :o4, 1490454000
          tz.transition 2017, 10, :o1, 1509202800
          tz.transition 2018, 3, :o4, 1521903600
          tz.transition 2018, 10, :o1, 1540652400
          tz.transition 2019, 3, :o4, 1553958000
          tz.transition 2019, 10, :o1, 1572102000
          tz.transition 2020, 3, :o4, 1585407600
          tz.transition 2020, 10, :o1, 1603551600
          tz.transition 2021, 3, :o4, 1616857200
          tz.transition 2021, 10, :o1, 1635606000
          tz.transition 2022, 3, :o4, 1648306800
          tz.transition 2022, 10, :o1, 1667055600
          tz.transition 2023, 3, :o4, 1679756400
          tz.transition 2023, 10, :o1, 1698505200
          tz.transition 2024, 3, :o4, 1711810800
          tz.transition 2024, 10, :o1, 1729954800
          tz.transition 2025, 3, :o4, 1743260400
          tz.transition 2025, 10, :o1, 1761404400
          tz.transition 2026, 3, :o4, 1774710000
          tz.transition 2026, 10, :o1, 1792854000
          tz.transition 2027, 3, :o4, 1806159600
          tz.transition 2027, 10, :o1, 1824908400
          tz.transition 2028, 3, :o4, 1837609200
          tz.transition 2028, 10, :o1, 1856358000
          tz.transition 2029, 3, :o4, 1869058800
          tz.transition 2029, 10, :o1, 1887807600
          tz.transition 2030, 3, :o4, 1901113200
          tz.transition 2030, 10, :o1, 1919257200
          tz.transition 2031, 3, :o4, 1932562800
          tz.transition 2031, 10, :o1, 1950706800
          tz.transition 2032, 3, :o4, 1964012400
          tz.transition 2032, 10, :o1, 1982761200
          tz.transition 2033, 3, :o4, 1995462000
          tz.transition 2033, 10, :o1, 2014210800
          tz.transition 2034, 3, :o4, 2026911600
          tz.transition 2034, 10, :o1, 2045660400
          tz.transition 2035, 3, :o4, 2058361200
          tz.transition 2035, 10, :o1, 2077110000
          tz.transition 2036, 3, :o4, 2090415600
          tz.transition 2036, 10, :o1, 2108559600
          tz.transition 2037, 3, :o4, 2121865200
          tz.transition 2037, 10, :o1, 2140009200
          tz.transition 2038, 3, :o4, 19724081, 8
          tz.transition 2038, 10, :o1, 19725817, 8
          tz.transition 2039, 3, :o4, 19726993, 8
          tz.transition 2039, 10, :o1, 19728729, 8
          tz.transition 2040, 3, :o4, 19729905, 8
          tz.transition 2040, 10, :o1, 19731641, 8
          tz.transition 2041, 3, :o4, 19732873, 8
          tz.transition 2041, 10, :o1, 19734553, 8
          tz.transition 2042, 3, :o4, 19735785, 8
          tz.transition 2042, 10, :o1, 19737465, 8
          tz.transition 2043, 3, :o4, 19738697, 8
          tz.transition 2043, 10, :o1, 19740377, 8
          tz.transition 2044, 3, :o4, 19741609, 8
          tz.transition 2044, 10, :o1, 19743345, 8
          tz.transition 2045, 3, :o4, 19744521, 8
          tz.transition 2045, 10, :o1, 19746257, 8
          tz.transition 2046, 3, :o4, 19747433, 8
          tz.transition 2046, 10, :o1, 19749169, 8
          tz.transition 2047, 3, :o4, 19750401, 8
          tz.transition 2047, 10, :o1, 19752081, 8
          tz.transition 2048, 3, :o4, 19753313, 8
          tz.transition 2048, 10, :o1, 19754993, 8
          tz.transition 2049, 3, :o4, 19756225, 8
          tz.transition 2049, 10, :o1, 19757961, 8
          tz.transition 2050, 3, :o4, 19759137, 8
          tz.transition 2050, 10, :o1, 19760873, 8
        end
      end
    end
  end
end
