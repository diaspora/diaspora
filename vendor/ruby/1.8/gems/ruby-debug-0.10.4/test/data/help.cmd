# $Id: setshow.cmd 298 2007-08-28 10:07:35Z rockyb $
# This tests the functioning of some set/show debugger commands
set debuggertesting on
set autoeval off
set width 80
### *******************************
### ***   help commands         ***
### *******************************
help foo
help set listsize
help show anno
help show foo
help info file
help info file all
help info file br
help info files

# FIXME - the below should work
# help 
# help step
