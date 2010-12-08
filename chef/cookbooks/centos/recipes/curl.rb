execute "download curl into usr/local" do
  command "mkdir -p /usr/local && cd /usr/local/ && wget http://curl.haxx.se/download/curl-7.19.7.tar.gz"
end

execute "configure, make, and install curl" do
  command "tar -xvzf curl-7.19.7.tar.gz && cd /usr/local/curl-7.19.7 && ./configure && make && make install"
end

execute 'update dynamic loader cache for curl' do
  command "echo '/usr/local/lib' >> /etc/ld.so.conf"
  not_if "grep /usr/local/lib /etc/ld.so.conf"
end

execute 'run dynamic linker' do
  command '/sbin/ldconfig'
end

execute 'add bundler line' do
  command 'cd /usr/local/app/diaspora/ && bundle config build.typhoeus --with-curl=/usr/local/curl-7.19.7/'
end

execute 'rebundle' do
  command 'bundle install'
end
