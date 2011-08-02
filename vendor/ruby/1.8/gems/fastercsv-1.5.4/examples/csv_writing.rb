#!/usr/local/bin/ruby -w

# csv_rails_import.rb
#
#  Created by James Edward Gray II on 2006-11-05.
#  Copyright 2006 Gray Productions. All rights reserved.

require "faster_csv"

CSV_FILE_PATH = File.join(File.dirname(__FILE__), "output.csv")

# writing to a file
FasterCSV.open(CSV_FILE_PATH, "w") do |csv|
  csv << %w[first last]
  csv << %w[James Gray]
  csv << %w[Dana Gray]
end
puts File.read(CSV_FILE_PATH)
# >> first,last
# >> James,Gray
# >> Dana,Gray

# appending to an existing file
FasterCSV.open(CSV_FILE_PATH, "a") do |csv|
  csv << %w[Gypsy]
  csv << %w[Storm]
end
puts File.read(CSV_FILE_PATH)
# >> first,last
# >> James,Gray
# >> Dana,Gray
# >> Gypsy
# >> Storm

# writing to a string
csv_str = FasterCSV.generate do |csv|
  csv << %w[first last]
  csv << %w[James Gray]
  csv << %w[Dana Gray]
end
puts csv_str
# >> first,last
# >> James,Gray
# >> Dana,Gray

# appending to an existing string
FasterCSV.generate(csv_str) do |csv|
  csv << %w[Gypsy]
  csv << %w[Storm]
end
puts csv_str
# >> first,last
# >> James,Gray
# >> Dana,Gray
# >> Gypsy
# >> Storm

# changing the output format
csv_str = FasterCSV.generate(:col_sep => "\t") do |csv|
  csv << %w[first last]
  csv << %w[James Gray]
  csv << %w[Dana Gray]
end
puts csv_str
# >> first	last
# >> James	Gray
# >> Dana	Gray
