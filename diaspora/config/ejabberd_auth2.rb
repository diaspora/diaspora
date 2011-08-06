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
  require 'logger'
  require 'digest/sha1'
  require 'yaml'
  require 'dbi'
  
  def initialize

    path = "/home/lasek/diaspora/log/ejabberd_auth.log"
    file = File.open(path, File::WRONLY | File::APPEND | File::CREAT)
    file.sync = true
    @logger = Logger.new(file)
    @logger.level = Logger::DEBUG

    environment = 'development'
    config_file = '/home/lasek/diaspora/config/database.yml'

    cfg = YAML.load_file(config_file)[environment]

    host = cfg['host'] || '127.0.0.1'
    database = cfg['database']
    pwd = cfg['password']
    user = cfg['username']

    db_con = "DBI:Mysql:#{database}:#{host}"
    @db = DBI.connect db_con, user , pwd

    @logger.info "Starting ejabberd authentication service"

    buffer = String.new

    while STDIN.sysread(2, buffer) && buffer.length == 2

      length = buffer.unpack('n')[0]

      operation, username, domain, password = STDIN.sysread(length).split(':')
       
      @logger.info "Operation: #{operation}"

      response = case operation
      when 'auth'
        auth username, password.chomp
      when 'isuser'
        isuser username
      else
        0
      end

      STDOUT.syswrite([2, response].pack('nn'))
    end

  rescue Exception => exception
    puts 'Exception ' + exception.to_s
  ensure
    disconnect
  end

  def auth(username, password)
    @logger.info "Auth"
    row = @db.select_one("select encrypted_password from users where username = ? and created_at IS NOT NULL", username)
    @logger.info "Row1 #{row}"
    return (1 if row and authenticated?(row['encrypted_password'], password)) || 0
  end

  def authenticated?(crypted_password, password)
    @logger.info "Auth?"
    pass = Digest::SHA1.hexdigest("--#{password}--")
    @logger.info "Row2 #{pass}"
    crypted_password == pass
  end

  def isuser(username)
    @db.select_one('select 1 from users where username = ? and created IS NOT NULL', username) ? 1 : 0
  end

  def disconnect
    @db.disconnect if @db
    exit
  end

  EjabberdAuthentication.new

end