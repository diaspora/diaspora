#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



## Special package, anything that defines a 'source' package means build-essential should be installed for Ubuntu

package :build_essential do
  description 'Build tools'
  apt 'build-essential' do
    # Update the sources and upgrade the lists before we build essentials
    pre :install, 'apt-get update'
  end
end

package :tools do
  description 'Useful tools'
  apt 'psmisc htop elinks screen'
end

package :vim do
  apt 'vim' do 
    post :install, run("rm -r -f /root/vim-files")
  end
  apt 'vim' do 
    post :install, run("git clone git://github.com/zhitomirskiyi/vim-files.git /root/vim-files")
  end
  apt 'vim' do 
    post :install, run("ln -s -f /root/vim-files/vimrc /root/.vimrc") 
  end
  apt 'vim' do 
    post :install, run("ln -s -f -T /root/vim-files /root/.vim")
  end
end
