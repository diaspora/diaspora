#!/usr/bin/env ruby
# Test Debugger.catchpoint and post-mortem handling
def zero_div
  x = 5
  1/0
end
x = 2
zero_div
raise RuntimeError
x = 3

