execute "download curl into usr/local" do
  command "mkdir -p /usr/local && wget http://curl.haxx.se/download/curl-7.19.7.tar.gz"
end

execute "configure, make, and install curl" do
  command "cd /usr/local/curl-7.19.7 && tar -xvzf curl-7.19.7.tar.gz && ./configure && make && make install"
end

execute 'add bundler line' do
  command 'cd /usr/local/app/diaspora/ && bundle config build.typhoeus --with-curl=/usr/local/curl-7.19.7/'
end

execute 'rebundle' do
  command 'bundle install'
end
