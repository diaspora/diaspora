#!/usr/bin/env ruby -w

# limit.rb
# 
#  Created by James Edward Gray II on 2008-11-12.
#  Copyright 2008 Gray Productions. All rights reserved.

require "rubygems"
require "highline/import"

text = ask("Enter text (max 10 chars): ") { |q| q.limit = 10 }
puts "You entered: #{text}!"
