package :git, :provides => :scm do
  description 'Git Distributed Version Control'
	apt %w( git-core ) do 
    pre :install, "rm -rf /root/.ssh/"
    pre :install, "mkdir -p /root/.ssh/"
  end
  requires :pubkey
  requires :privkey
  requires :known_hosts
end

package :privkey do
  description 'checkout from github with it'
  transfer "#{File.dirname(__FILE__)}/../deploy_key/id_rsa", '/root/.ssh/id_rsa', :render => false
end

package :pubkey do
  transfer "#{File.dirname(__FILE__)}/../deploy_key/id_rsa.pub", '/root/.ssh/id_rsa.pub', :render => false 
end

package :known_hosts do
  transfer "#{File.dirname(__FILE__)}/../deploy_key/known_hosts", '/root/.ssh/known_hosts', :render => false 
end
