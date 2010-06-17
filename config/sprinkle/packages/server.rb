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
