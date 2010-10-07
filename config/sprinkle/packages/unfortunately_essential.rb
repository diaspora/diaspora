#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#Fix dreamhost
#

package :clean_dreamhost do
  description 'removes roadblocks in the standard DH PS image'
  run 'apt-get -fy install'
  run 'apt-get -y remove ruby'
  run 'apt-get  -y remove ruby1.8 --purge'
end
