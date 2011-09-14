execute "Get nginx from nginx web site" do
  command "mkdir -p /tmp/install && curl http://sysoev.ru/nginx/nginx-0.8.53.tar.gz > /tmp/install/nginx-0.8.53.tar.gz" 
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

cookbook_file "/usr/local/nginx/html/crossdomain.xml" do
  source "crossdomain.xml"
end

execute "change crossdomain.xml permissions" do
  command "chmod 755 /usr/local/nginx/html/crossdomain.xml"
end

config = YAML.load_file("/usr/local/app/diaspora/chef/cookbooks/common/files/default/thins.yml")
template "/usr/local/nginx/conf/nginx.conf" do
  source "nginx.conf.erb"
  variables :ports => config['thins'].map{|thin| "#{thin["port"]}"}, :url => config['url'], :cert_location => config['cert_location'], :key_location => config['key_location'],
  :s3_bucket => config['s3_bucket'] , :s3_path => config['s3_path'] 
end
