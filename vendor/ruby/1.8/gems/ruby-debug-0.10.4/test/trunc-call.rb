#!/usr/bin/env ruby
# This program is used to test that 'restart' works when we didn't call
# the debugger initially.

TOP_SRC_DIR = File.join(File.expand_path(File.dirname(__FILE__), "..")) unless 
  defined?(TOP_SRC_DIR)

$:.unshift File.join(TOP_SRC_DIR, "ext")
$:.unshift File.join(TOP_SRC_DIR, "lib")
$:.unshift File.join(TOP_SRC_DIR, "cli")
require 'ruby-debug'

# GCD. We assume positive numbers
def gcd(a, b)
  # Make: a <= b
  if a > b
    a, b = [b, a]
  end
  if a==3
    Debugger.debugger
  end

  return nil if a <= 0

  if a == 1 or b-a == 0
    return a
  end
  return gcd(b-a, a)
end

gcd(13,8)
