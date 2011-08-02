require 'open4'
include Open4

cat = 'ruby -e"  ARGF.each{|line| STDOUT << line}  "'

stdout, stderr = '', ''
status = spawn cat, 'stdin' => '42', 'stdout' => stdout, 'stderr' => stderr
p status
p stdout
p stderr

stdout, stderr = '', ''
status = spawn cat, 0=>'42', 1=>stdout, 2=>stderr
p status
p stdout
p stderr
