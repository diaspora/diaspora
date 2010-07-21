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
  requires :vim
end

package :vim do
  run("cd && git clone git@github.com:zhitomirskiyi/vim-files.git")
  run("ln -s /root/vim-files/vimrc /root/.vimrc") 
  run("ln -s -f -T /root/vim-files /root/.vim")
end
