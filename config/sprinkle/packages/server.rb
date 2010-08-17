package :nginx do
  description 'Nginx HTTP server'
  version '0.7.67'
  source "http://nginx.org/download/nginx-#{version}.tar.gz"
  requires :nginx_dependencies
end

package :nginx_conf, :provides=> :webserver do
  description 'Nginx conf file'
  transfer "#{File.dirname(__FILE__)}/../conf/nginx.conf", '/usr/local/conf/nginx.conf', :render => true do
    pre :install, "mkdir -p /usr/local/sbin/conf/"
  end
  requires :nginx
end

package :nginx_dependencies do
  description 'Nginx build dependencies'
  apt %w( libc6 libpcre3 libpcre3-dev libssl0.9.8)
  source "http://zlib.net/zlib-1.2.5.tar.gz"
end
