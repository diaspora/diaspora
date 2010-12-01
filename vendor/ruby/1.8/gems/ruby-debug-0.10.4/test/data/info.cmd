# ***************************************************
# This tests info command handling
# ***************************************************
set debuggertesting on
set callstyle last
help info
info args
info line
info locals
info stack
info display
help info break
help info display
break 10
break 12
info break 10
info break 1
info break 1 2
info break
info file ./gcd.rb break
i
quit
