#
# of course stdin can be supplied too.  synonyms for 'stdin' include '0' and
# 0.  the other stdio streams have similar shortcuts
#
  require 'systemu'

  cat = %q( ruby -e"  ARGF.each{|line| puts line}  " )

  status = systemu cat, 0=>'the stdin for cat', 1=>stdout=''
  puts stdout
