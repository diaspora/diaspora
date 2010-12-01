# ********************************************************
# This tests the 'method' command
# ********************************************************
set debuggertesting on
set autoeval off
b 3
c
method sig initialize
method sig mymethod
quit
