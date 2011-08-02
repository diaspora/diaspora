# ***************************************************
# This tests display expressions.
# ***************************************************
set debuggertesting on
b 6
c
# Should be no display expression yet.
info display
display a
display b 
disable display b
disable display 1
c
enable display b
enable display 1
undisplay a
undisplay 2
# Should have only one display expression.
info display
undisplay 1
# Now we have no more display expressions.
info display
q

