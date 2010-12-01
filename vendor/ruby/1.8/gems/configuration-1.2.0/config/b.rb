Configuration.for('b'){
  host "codeforpeople.com"

  www {
    port 80
    url "http://#{ host }:#{ port }"
  }

  db {
    port 5342 
    url "db://#{ host }:#{ port }"
  }

  mail {
    host "gmail.com"
    port 25 
    url "mail://#{ host }:#{ port }"
  }
}
