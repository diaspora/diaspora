execute "get the daemontools repo" do
  command "mkdir -p /package/admin && cd /package/admin && git clone git://github.com/MikeSofaer/daemontools.git daemontools-0.76 || true"
end

execute "compile daemontools" do
  command "cd /package/admin/daemontools-0.76 && ./package/install"
end

execute "mongo run" do
  command "mkdir -p /service/mongo && echo '#!/bin/sh' > /service/mongo/run && echo 'exec /usr/bin/mongod' >> /service/mongo/run"
end
execute "executable" do
  command "chmod -R 755 /service/mongo"
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

#service for mongo tunnel
#execute "mongo ssh tunnel" do
  #command "mkdir -p /service/mongo_ssh_tunnel && echo '#!/bin/sh' > /service/mongo_ssh_tunnel/run && echo 'exec ssh -N -f -L 27017:localhost:27017 caesar@184.106.233.43' >> /service/websocket/run"
#end

execute "websocket run" do
  command "mkdir -p /service/websocket && echo '#!/bin/sh' > /service/websocket/run && echo 'cd /usr/local/app/diaspora && RAILS_ENV=production exec /usr/local/bin/ruby /usr/local/app/diaspora/script/websocket_server.rb' >> /service/websocket/run"
end
execute "executable" do
  command "chmod -R 755 /service/websocket"
end

execute "magent run" do
  command "mkdir -p /service/magent && echo '#!/bin/sh' > /service/magent/run && echo 'cd /usr/local/app/diaspora && RAILS_ENV=production exec /usr/local/bin/ruby /usr/local/bin/magent start --log-path=log/' >> /service/magent/run"
end
execute "executable" do
  command "chmod -R 755 /service/magent"
end

execute "nginx run" do
  command "mkdir -p /service/nginx && echo '#!/bin/sh' > /service/nginx/run && echo 'exec /usr/local/nginx/sbin/nginx' >> /service/nginx/run"
end
execute "executable" do
  command "chmod -R 755 /service/nginx"
end
