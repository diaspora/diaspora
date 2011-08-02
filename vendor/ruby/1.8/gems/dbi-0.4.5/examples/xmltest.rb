require "dbi"

DBI.connect("dbi:Oracle:oracle.neumann") do |dbh|
  dbh.execute("SELECT * FROM EMP") do |sth|
    DBI::Utils::XMLFormatter.table(sth.fetch_all, "EMP")
  end
end

