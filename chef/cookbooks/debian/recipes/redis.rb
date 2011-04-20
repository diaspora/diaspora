execute "download redis" do
  command "wget http://ftp.us.debian.org/debian/pool/main/r/redis/redis-server_2.2.2-1_amd64.deb"
end

execute "install redis" do
  command "dpkg -i redis-server_2.2.2-1_amd64.deb"
end

cookbook_file "/usr/local/etc/redis.conf" do
  source "redis.conf"
end

execute "change redis.conf permissions" do
  command "chmod 755 /usr/local/etc/redis.conf"
end

execute "make the redis db directory" do
  command "mkdir -p /usr/local/var/db/redis"
end
