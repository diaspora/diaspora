execute "install mysql" do
  command "apt-get install -y mysql-server libmysqlclient-dev libmysql-ruby"
end

execute "start mysql service to create the system tables" do
  command "service mysqld start"
end

execute "stop service again" do
  command "service mysqld stop"
end
