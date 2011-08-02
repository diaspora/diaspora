#  (c) Copyright 2006 David Calavera.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.


#!/usr/bin/ruby

class EjabberdAuthentication
  require 'rubygems'
  #require 'digest/sha1'
  require 'yaml'
  require 'dbi'

  def initialize

    environment = 'development'
    config_file = './config/database.yml'

    cfg = YAML.load_file(config_file)[environment]

    host = cfg['host'] || '127.0.0.1'
    database = cfg['database']
    pwd = cfg['password']
    user = cfg['username']

    db_con = "DBI:Mysql:#{database}:#{host}"
    @db = DBI.connect db_con, user , pwd

    users = @db.select_all("select username from users")
    users.each do |username|
      adduser username.to_s, host
    end

    rows = @db.select_all("select user_id, person_id, id from contacts where sharing = 1 and receiving = 1")
    rows.each do |row|
      username = @db.select_one("select username from users where id = ?", row[0])
      person = @db.select_one("select diaspora_handle from people where id = ?", row[1])
      nick = @db.select_one("select first_name, last_name from profiles where person_id = ?", row[1])
      aspect_id = @db.select_one("select aspect_id from aspect_memberships where contact_id = ?", row[2])
      aspect =  @db.select_one("select name from aspects where id = ?", aspect_id)
      printf "User: %d %s@#{host}, Person: %d handler: %s nick: %s %s, Aspect: %s\n", row[0], username, row[1], person, nick[0], nick[1], aspect
      addroster username.to_s, host.to_s, person.to_s, nick[0].to_s + " " + nick[1].to_s, aspect.to_s
    end

  rescue Exception => exception
    puts 'Exception ' + exception.to_s
  ensure
    disconnect
  end

  def addroster(username, host, person, nick, group)
    friend = person.split('@')
    phost = friend[1].split(':')[0]
    #printf "ejabberdctl add_rosteritem %s %s %s %s %s %s both\n", username, host, friend[0], phost, '"'+nick+'"' , group
    system "sudo ejabberdctl", "add_rosteritem", username, host, friend[0], phost, '"'+nick+'"' , group, "both"
  end

  def adduser(username, host)
    #printf "ejabberdctl register %s %s %s\n",username, host, ""
    system "sudo ejabberdctl", "register", username, host , ""
  end

  def disconnect
    @db.disconnect if @db
    exit
  end

  EjabberdAuthentication.new

end