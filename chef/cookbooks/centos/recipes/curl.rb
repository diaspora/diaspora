curl = 'curl-7.21.4'

execute 'download curl' do
  command "mkdir -p /tmp/install && wget http://curl.download.nextag.com/download/#{curl}.tar.gz"
  not_if do
    File.exists?("/tmp/install/#{curl}.tar.gz")
  end
end

execute "unzip curl" do
  command "cd /tmp/install && tar -xvf #{curl}.tar.gz"
  not_if do
    File.exists?("/tmp/install/#{curl}/README")
  end
end

execute "configure curl" do
  command "cd /tmp/install/#{curl} && ./configure --with-ssl"
  #not_if do
  #  the libcurl so file is there
  #end
end

execute "compile curl" do
  command "cd /tmp/install/#{curl} && make"
end

execute "install curl" do
  command "cd /tmp/install/#{curl} && make install"
end

execute 'update dynamic loader cache for curl' do
  command "echo '/usr/local/lib' >> /etc/ld.so.conf"
  not_if "grep /usr/local/lib /etc/ld.so.conf"
end

execute 'run dynamic linker' do
  command '/sbin/ldconfig'
end

#execute 'add bundler line' do
#  command "cd /usr/local/app/diaspora/ && bundle config build.typhoeus --with-curl=/usr/local/#{curl}/"
#end

#execute 'rebundle' do
#  command 'bundle install'
#end
