#!/usr/local/bin/ruby -w

# csv_table.rb
#
#  Created by James Edward Gray II on 2006-11-04.
#  Copyright 2006 Gray Productions. All rights reserved.
# 
# Feature implementation and example code by Ara.T.Howard.

require "faster_csv"

table = FCSV.parse(DATA, :headers => true, :header_converters => :symbol)

# row access
table[0].class   # => FasterCSV::Row
table[0].fields  # => ["zaphod", "beeblebrox", "42"]

# column access
table[:first_name]  # => ["zaphod", "ara"]

# cell access
table[1][0]            # => "ara"
table[1][:first_name]  # => "ara"
table[:first_name][1]  # => "ara"

# manipulation
table << %w[james gray 30]
table[-1].fields  # => ["james", "gray", "30"]

table[:type] = "name"
table[:type]  # => ["name", "name", "name"]

table[:ssn] = %w[123-456-7890 098-765-4321]
table[:ssn]  # => ["123-456-7890", "098-765-4321", nil]

# iteration
table.each do |row|
  # ...
end

table.by_col!
table.each do |col_name, col_values|
  # ...
end

# output
puts table
# >> first_name,last_name,age,type,ssn
# >> zaphod,beeblebrox,42,name,123-456-7890
# >> ara,howard,34,name,098-765-4321
# >> james,gray,30,name,

__END__
first_name,last_name,age
zaphod,beeblebrox,42
ara,howard,34
