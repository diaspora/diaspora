case node['platform']
when "debian"

  remote_file "#{Chef::Config[:file_cache_path]}/redis-server_2.2.2-1_amd64.deb" do
    source "wget http://ftp.us.debian.org/debian/pool/main/r/redis/redis-server_2.2.2-1_amd64.deb"
  end

  dpkg_package "redis-server" do
    source "#{Chef::Config[:file_cache_path]}/redis-server_2.2.2-1_amd64.deb"
  end  

when "centos"

  execute "refresh yum" do
    command "yum update -y"
  end

  package "redis"

end

cookbook_file "/usr/local/etc/redis.conf" do
  source "redis.conf"
  mode 0755
end

directory "/usr/local/var/db/redis" do
  recursive true
end
