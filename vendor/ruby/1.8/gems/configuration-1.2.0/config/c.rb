%w( development production testing ).each do |environment|

  Configuration.for(environment){
    adapter "sqlite3"
    db "db/#{ environment }"
  }

end
