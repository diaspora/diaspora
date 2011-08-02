use DBI;

$dbh = DBI->connect("dbi:Oracle:oracle.neumann", "scott", "tiger", {RaiseError => 1, AutoCommit => 0} );


$dbh->do("DROP TABLE MYTEST");
$dbh->do("CREATE TABLE MYTEST (a INT, b VARCHAR2(256), c FLOAT, d VARCHAR2(256))");

$sth = $dbh->prepare("INSERT INTO MYTEST VALUES (:1, :2, :3, :4)");

$i = 1;

while ($i <= 10000) {
  
  $sth->execute($i, "Michael der $i. von Neumann", 5.6 * $i, "HALLO LEUTE WIE GEHTS DENN SO?");
  
  $i = $i + 1;
  #print $i, "\n";
}


$dbh->commit();





#$sth = $dbh->prepare("SELECT * FROM EMP");

#$sth->execute();

#while (@row = $sth->fetchrow_array()) {
#  print(@row);
#}  


$dbh->disconnect();


