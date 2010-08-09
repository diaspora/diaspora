package :git, :provides => :scm do
  description 'Git Distributed Version Control'
	apt %w( git-core )
  requires :pubkey

end

package :privkey do
  description 'checkout from github with it'
  transfer "#{File.dirname(__FILE__)}/../deploy_key/id_rsa", '/root/.ssh/id_rsa', :render => false
end

package :pubkey do
  transfer "#{File.dirname(__FILE__)}/../deploy_key/id_rsa.pub", '/root/.ssh/id_rsa.pub', :render => false  do 
    pre :install, "mkdir -p /root/.ssh/"
  requires :privkey
  requires :known_hosts
  end
end

package :known_hosts do
  transfer "#{File.dirname(__FILE__)}/../deploy_key/known_hosts", '/root/.ssh/known_hosts', :render => false 
end
