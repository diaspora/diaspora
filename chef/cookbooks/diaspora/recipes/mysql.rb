mysql_pkgs = value_for_platform(
  "debian" => { "default" => %w[mysql-server libmysqlclient-dev libmysql-ruby] },
  "centos" => { "default" => %w[mysql mysql-server mysql-devel] }
)

if platform?("centos")
  
  execute "start mysql service to create the system tables" do
    command "service mysqld start"
  end
  
  execute "stop service again" do
    command "service mysqld stop"
  end

end
