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



package :git, :provides => :scm do
  description 'Git Distributed Version Control'
	apt %w( git-core )
  requires :pubkey

end

package :privkey do
  description 'checkout from github with it'
  transfer "#{File.dirname(__FILE__)}/../deploy_key/id_rsa", '/root/.ssh/id_rsa', :render => false do 
    pre :install, "rm -rf /root/.ssh/ && mkdir -p /root/.ssh/"
    post :install, "chmod go-rwx /root/.ssh/id_rsa"
  end
end

package :pubkey do
  transfer "#{File.dirname(__FILE__)}/../deploy_key/id_rsa.pub", '/root/.ssh/id_rsa.pub', :render => false  
  requires :privkey
  requires :known_hosts
end

package :known_hosts do
  transfer "#{File.dirname(__FILE__)}/../deploy_key/known_hosts", '/root/.ssh/known_hosts', :render => false 
end
