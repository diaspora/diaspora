#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

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
