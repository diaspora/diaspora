execute "get the daemontools repo" do
  command "mkdir -p /package/admin && cd /package/admin && git clone git://github.com/MikeSofaer/daemontools.git daemontools-0.76 || true"
end

execute "compile daemontools" do
  command "cd /package/admin/daemontools-0.76 && ./package/install"
end

execute "mysql run" do
  command "mkdir -p /service/mysql && echo '#!/bin/sh' > /service/mysql/run && echo 'exec /usr/bin/mysqld_safe --datadir=/var/lib/mysql --socket=/var/lib/mysql/mysql.sock --log-error=/var/log/mysqld.log --pid-file=/var/run/mysqld/mysqld.pid --user=mysql'  >> /service/mysql/run"
end
execute "executable" do
  command "chmod -R 755 /service/mysql"
end

config = YAML.load_file("/usr/local/app/diaspora/chef/cookbooks/common/files/default/thins.yml")

config['thins'].each do |thin|
  port = thin["port"]
  dir = "/service/thin_#{port}"
  flags = []
  flags << "-c /usr/local/app/diaspora" #directory to run from
  flags << "-e production"              #run in production mode
  flags << "-p #{port}"                 #use a socket
  execute "thin run" do
    command "mkdir -p #{dir} && echo '#!/bin/sh' > #{dir}/run && echo 'exec /usr/local/bin/ruby /usr/local/bin/thin start #{flags.join(" ")}' >> #{dir}/run"
  end
  execute "executable" do
    command "chmod -R 755 " + dir
  end
end

execute "websocket run" do
  command "mkdir -p /service/websocket && echo '#!/bin/sh' > /service/websocket/run && echo 'cd /usr/local/app/diaspora && RAILS_ENV=production exec /usr/local/bin/ruby /usr/local/app/diaspora/script/websocket_server.rb' >> /service/websocket/run"
end
execute "executable" do
  command "chmod -R 755 /service/websocket"
end

execute "redis run" do
  command "mkdir -p /service/redis && echo '#!/bin/sh' > /service/redis/run && echo 'cd /usr/sbin/ && exec /usr/sbin/redis-server /usr/local/etc/redis.conf'  >> /service/redis/run"
end
execute "executable" do
  command "chmod -R 755 /service/redis"
end

execute "nginx run" do
  command "mkdir -p /service/nginx && echo '#!/bin/sh' > /service/nginx/run && echo 'exec /usr/local/nginx/sbin/nginx' >> /service/nginx/run"
end

execute "executable" do
  command "chmod -R 755 /service/nginx"
end

execute "resque worker run" do
  command "mkdir -p /service/resque_worker && echo '#!/bin/sh' > /service/resque_worker/run && echo 'cd /usr/local/app/diaspora && RAILS_ENV=production QUEUES=socket_webfinger,receive,receive_salmon,mail,http HOME=/usr/local/app/diaspora exec /usr/local/bin/rake resque:work' >> /service/resque_worker/run"
end

execute "executable" do
  command "chmod -R 755 /service/resque_worker"
end

execute "resque web run" do
  command "mkdir -p /service/resque_web && echo '#!/bin/sh' > /service/resque_web/run && echo 'RAILS_ENV=production HOME=/usr/local/app/diaspora exec resque-web -F' >> /service/resque_web/run"
end

execute "executable" do
  command "chmod -R 755 /service/resque_web"
end
