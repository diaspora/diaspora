#!/usr/bin/env ruby
# Adapted from Programming Ruby 2nd Ed. p. 138
require 'rubygems'

unless defined?(Debugger)
  puts "This program has to be called from the debugger"
  exit 1
end

def fn(count, i)
  sleep(rand(0.1))
  if 4 == i
    debugger 
  end
  Thread.current['mycount'] = count
end

count = 0
threads = []
5.times do |i|
  threads[i] = Thread.new do
    fn(count, i)
    count += 1
    end
  end
threads.each {|t| t.join }
