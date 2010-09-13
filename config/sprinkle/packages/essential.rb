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
