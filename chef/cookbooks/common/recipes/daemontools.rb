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

execute "thin run" do
  command "mkdir -p /service/thin && echo '#!/bin/sh' > /service/thin/run && echo 'exec /usr/local/bin/ruby /usr/local/bin/thin start -c /usr/local/app/diaspora -p80' >> /service/thin/run"
end
execute "executable" do
  command "chmod -R 755 /service/thin"
end

execute "websocket run" do
  command "mkdir -p /service/websocket && echo '#!/bin/sh' > /service/websocket/run && echo 'cd /usr/local/app/diaspora && exec /usr/local/bin/ruby /usr/local/app/diaspora/script/websocket_server.rb' >> /service/websocket/run"
end
execute "executable" do
  command "chmod -R 755 /service/websocket"
end