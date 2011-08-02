# This tests the functioning of some set/show debugger commands
set debuggertesting on
### *******************************
### ***   save/source commands  ***
### *******************************
########################################
###   test args and baseneme...
########################################
set basename off
set autoeval off
# Should have nothing set
info break
info catch
# Should save nothing
save temp
eval File.open("temp").readlines
# Should read in nothing
source temp
info break
# Now try saving something interesting
break 10
catch RuntimeError
save temp
eval File.open("temp").readlines
# FIXME: The below is broken
## Change parameters above
## catch RuntimeError off
## info catch
##set listsize 55
source temp
##info break
##info catch
##show listsize
