execute "install mysql" do
  command "yum install -y mysql mysql-server mysql-devel"
end

execute "start mysql service to create the system tables" do
  command "service mysqld start"
end

execute "stop service again" do
  command "service mysqld stop"
end
