#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



package :nginx, :provides=> :webserver do
  description 'Nginx HTTP server'
  version '0.7.67'
  source "http://nginx.org/download/nginx-#{version}.tar.gz"
  requires :nginx_dependencies
end

package :nginx_conf do
  description 'Nginx conf file'
  transfer "#{File.dirname(__FILE__)}/../conf/nginx.conf", '/usr/local/conf/nginx.conf', :render => true do
    pre :install, "mkdir -p /usr/local/sbin/conf/"
  end
end

package :nginx_dependencies do
  description 'Nginx build dependencies'
  apt %w( libc6 libpcre3 libpcre3-dev libssl0.9.8)
  source "http://zlib.net/zlib-1.2.5.tar.gz"
end
