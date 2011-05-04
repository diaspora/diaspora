execute "install mysql" do
  command "apt-get install -y mysql-server libmysqlclient-dev libmysql-ruby"
end
