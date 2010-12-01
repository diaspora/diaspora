# ***************************************************
# Test handling of info variables when we have 
# redefined inspect or to_s which give an error.
# ***************************************************
set debuggertesting on
# Go to where we have a bad "inspect" of a local variable
continue 36
info variables
# Go to where we have a bad "inspect" and "to_s" of a local variable
continue 40
info variables
break 31
# The first time through, we can do inspect.
continue
info locals
# Now go to where we have a bad "inspect" of an class variable
continue
info locals
info variables
# Now go to where we have a bad "inspect" and "to_s" of an class variable
continue
info locals
quit
