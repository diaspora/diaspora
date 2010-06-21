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

=begin
package :mongrel do
  description 'Mongrel Application Server'
  gem 'mongrel'
  version '1.1.5'
end

package :mongrel_cluster, :provides => :appserver do
  description 'Cluster Management for Mongrel'
  gem 'mongrel_cluster'
  version '1.0.5'
  requires :mongrel
end

package :apache, :provides => :webserver do
  description 'Apache 2 HTTP Server'
  version '2.2.15'
	
  source "http://download.nextag.com/apache/httpd/httpd-#{version}.tar.bz2" do
    enable %w( mods-shared=all proxy proxy-balancer proxy-http rewrite cache headers ssl deflate so )
    prefix "/opt/local/apache2-#{version}"
    post :install, 'install -m 755 support/apachectl /etc/init.d/apache2', 'update-rc.d -f apache2 defaults'
  end
  requires :apache_dependencies
end

package :apache_dependencies do
  description 'Apache 2 HTTP Server Build Dependencies'
  apt %w( openssl libtool mawk zlib1g-dev libssl-dev )
end
=end
