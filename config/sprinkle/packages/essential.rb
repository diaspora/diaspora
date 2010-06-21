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
  apt 'psmisc htop'
end
