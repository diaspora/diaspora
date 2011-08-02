# ***************************************************
# Test catch
# ***************************************************
set debuggertesting on
set autoeval off
set basename on
info catch
catch ZeroDivisionError off
catch ZeroDivisionError off afdasdf
catch ZeroDivisionError
info catch
catch ZeroDivisionError off
info catch
catch ZeroDivisionError
c
where
quit
