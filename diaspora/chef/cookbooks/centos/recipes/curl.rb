curl = 'curl-7.21.4'

execute 'download curl' do
  command "mkdir -p /tmp/install && cd /tmp/install/ && wget http://curl.download.nextag.com/download/#{curl}.tar.gz"
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
  not_if do
    File.exists?('/usr/local/lib/libcurl.so.4')
  end
end

execute "compile curl" do
  command "cd /tmp/install/#{curl} && make"
  not_if do
    File.exists?('/usr/local/lib/libcurl.so.4')
  end
end

execute "install curl" do
  command "cd /tmp/install/#{curl} && make install"
  not_if do
    File.exists?('/usr/local/lib/libcurl.so.4')
  end
end

execute 'update dynamic loader cache for curl' do
  command "echo '/usr/local/lib' >> /etc/ld.so.conf"
  not_if "grep /usr/local/lib /etc/ld.so.conf"
end

execute 'run dynamic linker' do
  command '/sbin/ldconfig'
end

execute 'rebundle' do
  command 'bundle install'
end

include_recipe "centos::startcom_bundle"
