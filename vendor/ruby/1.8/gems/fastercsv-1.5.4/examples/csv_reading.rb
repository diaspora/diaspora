#!/usr/local/bin/ruby -w

# csv_reading.rb
#
#  Created by James Edward Gray II on 2006-11-05.
#  Copyright 2006 Gray Productions. All rights reserved.

require "faster_csv"

CSV_FILE_PATH = File.join(File.dirname(__FILE__), "purchase.csv")
CSV_STR       = <<END_CSV
first,last
James,Gray
Dana,Gray
END_CSV

# read a file line by line
FasterCSV.foreach(CSV_FILE_PATH) do |line|
  puts line[1]
end
# >> Product Description
# >> Text Editor
# >> MacBook Pros

# slurp file data
data = FasterCSV.read(CSV_FILE_PATH)
puts data.flatten.grep(/\A\d+\.\d+\Z/)
# >> 25.00
# >> 2499.00

# read a string line by line
FasterCSV.parse(CSV_STR) do |line|
  puts line[0]
end
# >> first
# >> James
# >> Dana

# slurp string data
data = FasterCSV.parse(CSV_STR)
puts data[1..-1].map { |line| "#{line[0][0, 1].downcase}.#{line[1].downcase}" }
# >> j.gray
# >> d.gray

# adding options to make data manipulation easy
total = 0
FasterCSV.foreach( CSV_FILE_PATH, :headers           => true,
                                  :header_converters => :symbol,
                                  :converters        => :numeric ) do |line|
  line_total = line[:quantity] * line[:price]
  total += line_total
  puts "%s: %.2f" % [line[:product_description], line_total]
end
puts "Total: %.2f" % total
# >> Text Editor: 25.00
# >> MacBook Pros: 4998.00
# >> Total: 5023.00
