#Fix dreamhost
#

package :clean_dreamhost do
  description 'removes roadblocks in the standard DH PS image'
  run 'apt-get -fy install'
  run 'apt-get -y remove ruby'
  run 'apt-get  -y remove ruby1.8 --purge'
end
