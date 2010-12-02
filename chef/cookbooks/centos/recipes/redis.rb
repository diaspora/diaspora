
execute "refresh yum" do
  command "yum update -y"
end

execute "install redis" do
  command "yum install -y redis"
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
