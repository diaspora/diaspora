# ********************************************************
# This tests the edit command
# ********************************************************
set debuggertesting on
# Edit using current line position.
edit
edit gcd.rb:5
# File should not exist
edit foo
# Add space to the end of 'edit'
edit 
quit
