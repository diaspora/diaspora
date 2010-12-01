#!/usr/local/bin/ruby -w

# = csv_filter.rb -- Faster CSV Reading and Writing
#
#  Created by James Edward Gray II on 2006-04-01.
#  Copyright 2006 Gray Productions. All rights reserved.

require "faster_csv"

running_total = 0
FasterCSV.filter( :headers           => true,
                  :return_headers    => true,
                  :header_converters => :symbol,
                  :converters        => :numeric ) do |row|
  if row.header_row?
    row << "Running Total"
  else
    row << (running_total += row[:quantity] * row[:price])
  end
end
# >> Quantity,Product Description,Price,Running Total
# >> 1,Text Editor,25.0,25.0
# >> 2,MacBook Pros,2499.0,5023.0
