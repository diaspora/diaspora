#!/usr/local/bin/ruby -w

require "rubygems"
require "highline/import"

pass = ask("Enter your password:  ") { |q| q.echo = false }
puts "Your password is #{pass}!"
