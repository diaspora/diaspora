#!/usr/bin/ruby

class EjabberdViewsCreator
  require 'rubygems'
  require 'yaml'
  require 'dbi'

  def initialize

    environment = 'development'
    config_file = './config/database.yml'

    cfg = YAML.load_file(config_file)[environment]

    host = cfg['host'] || '127.0.0.1'
    diaspdb = cfg['database']
    ejabbdb = cfg['ejabbdb']
    pwd = cfg['password']
    user = cfg['username']

    jdb_con = "DBI:Mysql:#{ejabbdb}:#{host}"
    @jdb = DBI.connect jdb_con, user , pwd

    @jdb.do("CREATE VIEW rosterusers AS SELECT username, SUBSTRING_INDEX(c.diaspora_handle,':',1) jid, IF(LENGTH(CONCAT(first_name, last_name))>0, CONCAT(first_name, ' ' ,last_name), SUBSTRING_INDEX(c.diaspora_handle,'@',1)) nick, 'B' subscription, 'N' ask, '' askmessage, 'N' server, '' subscribe, 'item' type, b.created_at FROM #{diaspdb}.users AS a JOIN #{diaspdb}.contacts AS b ON a.id = b.user_id JOIN #{diaspdb}.people AS c ON b.person_id = c.id JOIN #{diaspdb}.profiles AS d ON c.id = d.id WHERE b.sharing = 1 AND b.receiving = 1;")

    printf "View rosterusers created.\n"

    @jdb.do("CREATE VIEW rostergroups AS SELECT username, SUBSTRING_INDEX(e.diaspora_handle,':',1) jid, name grp FROM #{diaspdb}.aspect_memberships AS a JOIN #{diaspdb}.contacts AS b ON a.contact_id = b.id JOIN #{diaspdb}.aspects AS c ON a.aspect_id = c.id JOIN #{diaspdb}.users AS d ON d.id = b.user_id JOIN #{diaspdb}.people AS e ON e.id = b.person_id;")

    printf "View rostergroups created.\n"

  rescue Exception => exception
    puts 'Exception ' + exception.to_s
  ensure
    disconnect
  end

  def disconnect
    @dbj.disconnect if @dbj
    exit
  end

  EjabberdViewsCreator.new

end