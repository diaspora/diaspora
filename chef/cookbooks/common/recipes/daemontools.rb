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
