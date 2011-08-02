# ***************************************************
# This tests step, next, finish and continue
# ***************************************************
set debuggertesting on
set callstyle last
next
where
step a
set forcestep on
step- ; step-
set forcestep off
where
n 2
step+
where
step 3
step+
where
next+	
# finish
quit
