require "dbi"

dbh = DBI.connect("dbi:Oracle:oracle.neumann", "scott", "tiger", 'AutoCommit' => false)

dbh.do("DROP TABLE MYTEST")
dbh.do("CREATE TABLE MYTEST (a INT, b VARCHAR2(256), c FLOAT, d VARCHAR2(256))")

sth = dbh.prepare("INSERT INTO MYTEST VALUES (:1, :2, :3, :4)")

1.upto(10000) do |i|
  sth.execute(i.to_s, "Michael der #{i}. von Neumann", (5.6 * i).to_s, "HALLO LEUTE WIE GEHTS DENN SO?")
  #print i, "\n"
end

sth.finish

dbh.commit

dbh.disconnect

