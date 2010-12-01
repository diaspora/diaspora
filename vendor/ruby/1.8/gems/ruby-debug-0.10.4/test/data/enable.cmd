# ********************************************************
# This tests the enable command.
# ********************************************************
set debuggertesting on
set callstyle last
set autoeval off
break Object.gcd
# Should have a breakpoint 1
enable br 1
# Get help on enable
help enable
# Get help on just enable break
help enable break
# Plain enable should work
enable
# An invalid enable command
enable foo
quit


