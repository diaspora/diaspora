# ********************************************************
# This tests step, next, finish, continue, disable and 
# enable.
# FIXME: break out enable/disable
# ********************************************************
set debuggertesting on
set callstyle last
set autoeval off
break 6
break 10
continue
where
break Foo.bar
break Object.gcd
info break
continue
where
info program
c 10
info break
break foo
info break
disable  1
info break
enable breakpoint 1
enable br 10
delete 1
# We should see breakpoint 2 but not 1
info break
# We should still be able to access 2
disable 2
enable
enable foo
disable bar
disable
# We should be able to delete 2
delete 2 3
info break
# Should get a message about having no breakpoints.
disable 1
enable 1
# finish
quit
