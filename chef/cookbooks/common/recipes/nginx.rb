execute "Get nginx from nginx web site" do
  command "mkdir -p /tmp/install && curl http://sysoev.ru/nginx/nginx-0.8.53.tar.gz > /tmp/install/" 
end

execute "unzip nginx" do
  command "cd /tmp/install && tar -xvf nginx-0.8.53.tar.gz"
end

execute "configure nginx" do
  command "cd /tmp/install/nginx-0.8.53 && ./configure --with-http_ssl_module"
end

execute "compile nginx" do
  command "cd /tmp/install/nginx-0.8.53 && make"
end

execute "install nginx" do
  command "cd /tmp/install/nginx-0.8.53 && make install"
end
