#!/usr/local/bin/ruby -w

# csv_converters.rb
#
#  Created by James Edward Gray II on 2006-11-05.
#  Copyright 2006 Gray Productions. All rights reserved.

require "faster_csv"

# convert a specific column
options = {
  :headers           => true,
  :header_converters => :symbol,
  :converters        => [
    lambda { |f, info| info.index.zero?       ? f.to_i : f },
    lambda { |f, info| info.header == :floats ? f.to_f : f }
  ]
}
table = FCSV(DATA, options) { |csv| csv.read }

table[:ints]    # => [1, 2, 3]
table[:floats]  # => [1.0, 2.0, 3.0]

__END__
ints,floats
1,1.000
2,2
3,3.0
