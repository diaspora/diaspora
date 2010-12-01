# ********************************************************
# This tests step, next, continue, disable and 
# enable.
# FIXME: break out enable/disable
# ********************************************************
set debuggertesting on
set callstyle last
set autoeval off
break 6
break 10
break 11
continue
where
break Object.gcd
info break
continue
where
info program
c 6
info break
break foo
info break
disable  1
info break
delete 1
# We should see breakpoint 2 but not 1
info break
# We should still be able to access 2
disable 2
disable bar
disable
# We should be able to delete 2
delete 2 3
info break
# Should get a message about having no breakpoints.
disable 1
enable 1
q!
