#!/usr/local/bin/ruby -w

# shortcut_interface.rb
#
#  Created by James Edward Gray II on 2006-04-01.
#  Copyright 2006 Gray Productions. All rights reserved.
# 
# Feature implementation and example code by Ara.T.Howard.

require "faster_csv"

#
# So now it's this easy to write to STDOUT.
#
FCSV { |f| f << %w( a b c) << %w( d e f ) }

#
# Writing to a String.
#
FCSV(csv = '') do |f|
  f << %w( q r s )
  f << %w( x y z )
end
puts csv

#
# Writing to STDERR.
#
FCSV(STDERR) do |f|
  f << %w( 0 1 2 )
  f << %w( A B C )
end
# >> a,b,c
# >> d,e,f
# >> q,r,s
# >> x,y,z
